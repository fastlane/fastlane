module Fastlane
  # This class is responsible for checking the ARGV
  # to see if the user wants to launch another fastlane
  # tool or fastlane itself
  class CLIToolsDistributor
    class << self
      def running_version_command?
        ARGV.include?('-v') || ARGV.include?('--version')
      end

      def running_help_command?
        ARGV.include?('-h') || ARGV.include?('--help')
      end

      def running_init_command?
        ARGV.include?("init")
      end

      def utf8_locale?
        (ENV['LANG'] || "").end_with?("UTF-8", "utf8") || (ENV['LC_ALL'] || "").end_with?("UTF-8", "utf8") || (FastlaneCore::CommandExecutor.which('locale') && `locale charmap`.strip == "UTF-8")
      end

      def take_off
        before_import_time = Time.now

        if ENV["FASTLANE_DISABLE_ANIMATION"].nil?
          # Usually in the fastlane code base we use
          #
          #   Helper.show_loading_indicator
          #   longer_taking_task_here
          #   Helper.hide_loading_indicator
          #
          # but in this case we haven't required FastlaneCore yet
          # so we'll have to access the raw API for now
          require "tty-spinner"
          require_fastlane_spinner = TTY::Spinner.new("[:spinner] 🚀 ", format: :dots)
          require_fastlane_spinner.auto_spin

          # this might take a long time if there is no Gemfile :(
          # That's why we show the loading indicator here also
          require "fastlane"

          require_fastlane_spinner.success
        else
          require "fastlane"
        end

        # Loading any .env files before any lanes are called since
        # variables like FASTLANE_HIDE_CHANGELOG, SKIP_SLOW_FASTLANE_WARNING
        # and FASTLANE_DISABLE_COLORS need to be set early on in execution
        load_dot_env

        # We want to avoid printing output other than the version number if we are running `fastlane -v`
        unless running_version_command? || running_init_command?
          print_bundle_exec_warning(is_slow: (Time.now - before_import_time > 3))
        end

        # Try to check UTF-8 with `locale`, fallback to environment variables
        unless utf8_locale?
          warn = "WARNING: fastlane requires your locale to be set to UTF-8. To learn more go to https://docs.fastlane.tools/getting-started/ios/setup/#set-up-environment-variables"
          UI.error(warn)
          at_exit do
            # Repeat warning here so users hopefully see it
            UI.error(warn)
          end
        end

        # Needs to go after load_dot_env for variable FASTLANE_SKIP_UPDATE_CHECK
        FastlaneCore::UpdateChecker.start_looking_for_update('fastlane')

        # Disabling colors if environment variable set
        require 'fastlane_core/ui/disable_colors' if FastlaneCore::Helper.colors_disabled?

        # Set interactive environment variable for spaceship (which can't require fastlane_core)
        ENV["FASTLANE_IS_INTERACTIVE"] = FastlaneCore::UI.interactive?.to_s

        ARGV.unshift("spaceship") if ARGV.first == "spaceauth"
        tool_name = ARGV.first ? ARGV.first.downcase : nil

        tool_name = process_emojis(tool_name)
        tool_name = map_aliased_tools(tool_name)

        if tool_name && Fastlane::TOOLS.include?(tool_name.to_sym) && !available_lanes.include?(tool_name.to_sym)
          # Triggering a specific tool
          # This happens when the users uses things like
          #
          #   fastlane sigh
          #   fastlane snapshot
          #
          require tool_name
          begin
            # First, remove the tool's name from the arguments
            # Since it will be parsed by the `commander` at a later point
            # and it must not contain the binary name
            ARGV.shift

            # Import the CommandsGenerator class, which is used to parse
            # the user input
            require File.join(tool_name, "commands_generator")

            # Call the tool's CommandsGenerator class and let it do its thing
            commands_generator = Object.const_get(tool_name.fastlane_module)::CommandsGenerator
          rescue LoadError
            # This will only happen if the tool we call here, doesn't provide
            # a CommandsGenerator class yet
            # When we launch this feature, this should never be the case
            abort("#{tool_name} can't be called via `fastlane #{tool_name}`, run '#{tool_name}' directly instead".red)
          end

          # Some of the tools use other actions so need to load all
          # actions before we start the tool generator
          # Example: scan uses slack
          Fastlane.load_actions

          commands_generator.start
        elsif tool_name == "fastlane-credentials"
          require 'credentials_manager'
          ARGV.shift
          CredentialsManager::CLI.new.run
        else
          # Triggering fastlane to call a lane
          require "fastlane/commands_generator"
          Fastlane::CommandsGenerator.start
        end
      ensure
        FastlaneCore::UpdateChecker.show_update_status('fastlane', Fastlane::VERSION)
      end

      def map_aliased_tools(tool_name)
        Fastlane::TOOL_ALIASES[tool_name&.to_sym] || tool_name
      end

      # Since loading dotenv should respect additional environments passed using
      # --env, we must extract the arguments out of ARGV and process them before
      # calling into commander. This is required since the ENV must be configured
      # before running any other commands in order to correctly respect variables
      # like FASTLANE_HIDE_CHANGELOG and FASTLANE_DISABLE_COLORS
      def load_dot_env
        env_cl_param = lambda do
          index = ARGV.index("--env")
          return nil if index.nil?
          ARGV.delete_at(index)

          return nil if ARGV[index].nil?
          value = ARGV[index]
          ARGV.delete_at(index)

          value
        end

        require 'fastlane/helper/dotenv_helper'
        Fastlane::Helper::DotenvHelper.load_dot_env(env_cl_param.call)
      end

      # Since fastlane also supports the rocket and biceps emoji as executable
      # we need to map those to the appropriate tools
      def process_emojis(tool_name)
        return {
          "🚀" => "fastlane",
          "💪" => "gym"
        }[tool_name] || tool_name
      end

      def print_bundle_exec_warning(is_slow: false)
        return if FastlaneCore::Helper.bundler? # user is already using bundler
        return if FastlaneCore::Env.truthy?('SKIP_SLOW_FASTLANE_WARNING') # user disabled the warnings
        return if FastlaneCore::Helper.contained_fastlane? # user uses the bundled fastlane

        gemfile_path = PluginManager.new.gemfile_path
        if gemfile_path
          # The user has a Gemfile, but forgot to use `bundle exec`
          # Let's tell the user how to use `bundle exec`
          # We show this warning no matter if the command is slow or not
          UI.important("fastlane detected a Gemfile in the current directory")
          UI.important("However, it seems like you didn't use `bundle exec`")
          UI.important("To launch fastlane faster, please use")
          UI.message("")
          UI.command "bundle exec fastlane #{ARGV.join(' ')}"
          UI.message("")
        elsif is_slow
          # fastlane is slow and there is no Gemfile
          # Let's tell the user how to use `gem cleanup` and how to
          # start using a Gemfile
          UI.important("Seems like launching fastlane takes a while - please run")
          UI.message("")
          UI.command "[sudo] gem cleanup"
          UI.message("")
          UI.important("to uninstall outdated gems and make fastlane launch faster")
          UI.important("Alternatively it's recommended to start using a Gemfile to lock your dependencies")
          UI.important("To get started with a Gemfile, run")
          UI.message("")
          UI.command "bundle init"
          UI.command "echo 'gem \"fastlane\"' >> Gemfile"
          UI.command "bundle install"
          UI.message("")
          UI.important("After creating the Gemfile and Gemfile.lock, commit those files into version control")
        end
        UI.important("Get started using a Gemfile for fastlane https://docs.fastlane.tools/getting-started/ios/setup/#use-a-gemfile")
      end

      # Returns an array of symbols for the available lanes for the Fastfile
      # This doesn't actually use the Fastfile parser, but only
      # the available lanes. This way it's much faster, which
      # is very important in this case, since it will be executed
      # every time one of the tools is launched
      # Use this only if performance is :key:
      def available_lanes
        fastfile_path = FastlaneCore::FastlaneFolder.fastfile_path
        return [] if fastfile_path.nil?
        output = `cat #{fastfile_path.shellescape} | grep \"^\s*lane \:\" | awk -F ':' '{print $2}' | awk -F ' ' '{print $1}'`
        return output.strip.split(" ").collect(&:to_sym)
      end
    end
  end
end
