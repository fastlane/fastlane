module Fastlane
  # This class is responsible for checking the ARGV
  # to see if the user wants to launch another fastlane
  # tool or fastlane itself
  class CLIToolsDistributor
    class << self
      def running_version_command?
        ARGV.include?('-v') || ARGV.include?('--version')
      end

      def take_off
        before_import_time = Time.now

        require "fastlane" # this might take a long time if there is no Gemfile :(

        # We want to avoid printing output other than the version number if we are running `fastlane -v`
        if Time.now - before_import_time > 3 && !running_version_command?
          print_slow_fastlane_warning
        end

        ARGV.unshift("spaceship") if ARGV.first == "spaceauth"
        tool_name = ARGV.first ? ARGV.first.downcase : nil

        tool_name = process_emojis(tool_name)

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
            Object.const_get(tool_name.fastlane_module)::CommandsGenerator.start
          rescue LoadError
            # This will only happen if the tool we call here, doesn't provide
            # a CommandsGenerator class yet
            # When we launch this feature, this should never be the case
            abort("#{tool_name} can't be called via `fastlane #{tool_name}`, run '#{tool_name}' directly instead".red)
          end
        elsif tool_name == "fastlane-credentials"
          require 'credentials_manager'
          ARGV.shift
          CredentialsManager::CLI.new.run
        else
          # Triggering fastlane to call a lane
          require "fastlane/commands_generator"
          Fastlane::CommandsGenerator.start
        end
      end

      # Since fastlane also supports the rocket and biceps emoji as executable
      # we need to map those to the appropriate tools
      def process_emojis(tool_name)
        return {
          "🚀" => "fastlane",
          "💪" => "gym"
        }[tool_name] || tool_name
      end

      def print_slow_fastlane_warning
        # `BUNDLE_BIN_PATH` is used when the user uses `bundle exec`
        return if ENV['BUNDLE_BIN_PATH'] || ENV['SKIP_SLOW_FASTLANE_WARNING'] || FastlaneCore::Helper.contained_fastlane?

        gemfile_path = PluginManager.new.gemfile_path
        if gemfile_path
          # The user has a Gemfile, but fastlane is still slow
          # Let's tell the user how to use `bundle exec`
          UI.important "Seems like launching fastlane takes a while"
          UI.important "fastlane detected a Gemfile in this directory"
          UI.important "however it seems like you don't use `bundle exec`"
          UI.important "to launch fastlane faster, please use"
          UI.message ""
          UI.command "bundle exec fastlane #{ARGV.join(' ')}"
        else
          # fastlane is slow and there is no Gemfile
          # Let's tell the user how to use `gem cleanup` and how to
          # start using a Gemfile
          UI.important "Seems like launching fastlane takes a while - please run"
          UI.message ""
          UI.command "[sudo] gem cleanup"
          UI.message ""
          UI.important "to uninstall outdated gems and make fastlane launch faster"
          UI.important "Alternatively it's recommended to start using a Gemfile to lock your dependencies"
          UI.important "To get started with a Gemfile, run"
          UI.message ""
          UI.command "bundle init"
          UI.command "echo 'gem \"fastlane\"' >> Gemfile"
          UI.command "bundle install"
          UI.message ""
          UI.important "After creating the Gemfile and Gemfile.lock, commit those files into version control"
        end
        UI.important "For more information, check out https://guides.cocoapods.org/using/a-gemfile.html"

        sleep 1
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
