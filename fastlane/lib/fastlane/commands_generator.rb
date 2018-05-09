require 'commander'
require 'fastlane/new_action'

HighLine.track_eof = false

module Fastlane
  class CommandsGenerator
    include Commander::Methods

    def self.start
      # since at this point we haven't yet loaded commander
      # however we do want to log verbose information in the PluginManager
      FastlaneCore::Globals.verbose = true if ARGV.include?("--verbose")
      if ARGV.include?("--capture_output")
        FastlaneCore::Globals.verbose = true
        FastlaneCore::Globals.capture_output = true
      end
      FastlaneCore::Swag.show_loader

      # has to be checked here - in case we wan't to troubleshoot plugin related issues
      if ARGV.include?("--troubleshoot")
        self.confirm_troubleshoot
      end

      if FastlaneCore::Globals.capture_output?
        # Trace mode is enabled
        # redirect STDOUT and STDERR
        out_channel = StringIO.new
        $stdout = out_channel
        $stderr = out_channel
      end

      Fastlane.load_actions
      FastlaneCore::Swag.stop_loader
      # do not use "include" as it may be some where in the commandline where "env" is required, therefore explicit index->0
      unless ARGV[0] == "env" || CLIToolsDistributor.running_version_command? || CLIToolsDistributor.running_help_command?
        # *after* loading the plugins
        Fastlane.plugin_manager.load_plugins
        Fastlane::PluginUpdateManager.start_looking_for_updates
      end
      self.new.run
    ensure
      Fastlane::PluginUpdateManager.show_update_status
      if FastlaneCore::Globals.capture_output?
        if $stdout.respond_to?(:string)
          # Sometimes you can get NoMethodError: undefined method `string' for #<IO:<STDOUT>> when runing with FastlaneRunner (swift)
          FastlaneCore::Globals.captured_output = Helper.strip_ansi_colors($stdout.string)
        end
        $stdout = STDOUT
        $stderr = STDERR

        require "fastlane/environment_printer"
        Fastlane::EnvironmentPrinter.output
      end
    end

    def self.confirm_troubleshoot
      if Helper.ci?
        UI.error("---")
        UI.error("You are trying to use '--troubleshoot' on CI")
        UI.error("this option is not usable in CI, as it is insecure")
        UI.error("---")
        UI.user_error!("Do not use --troubleshoot in CI")
      end
      # maybe already set by 'start'
      return if $troubleshoot
      UI.error("---")
      UI.error("Are you sure you want to enable '--troubleshoot'?")
      UI.error("All commmands will run in full unfiltered output mode.")
      UI.error("Sensitive data, like passwords, could be printed to the log.")
      UI.error("---")
      if UI.confirm("Do you really want to enable --troubleshoot")
        $troubleshoot = true
      end
    end

    def run
      program :name, 'fastlane'
      program :version, Fastlane::VERSION
      program :description, [
        "CLI for 'fastlane' - #{Fastlane::DESCRIPTION}\n",
        "\tRun using `fastlane [platform] [lane_name]`",
        "\tTo pass values to the lanes use `fastlane [platform] [lane_name] key:value key2:value2`"
      ].join("\n")
      program :help, 'Author', 'Felix Krause <fastlane@krausefx.com>'
      program :help, 'Website', 'https://fastlane.tools'
      program :help, 'GitHub', 'https://github.com/fastlane/fastlane'
      program :help_formatter, :compact

      global_option('--verbose') { FastlaneCore::Globals.verbose = true }
      global_option('--capture_output', 'Captures the output of the current run, and generates a markdown issue template') do
        FastlaneCore::Globals.capture_output = false
        FastlaneCore::Globals.verbose = true
      end
      global_option('--troubleshoot', 'Enables extended verbose mode. Use with caution, as this even includes ALL sensitive data. Cannot be used on CI.')

      always_trace!

      command :trigger do |c|
        c.syntax = 'fastlane [lane]'
        c.description = 'Run a specific lane. Pass the lane name and optionally the platform first.'
        c.option('--env STRING[,STRING2]', String, 'Add environment(s) to use with `dotenv`')
        c.option('--disable_runner_upgrades', 'Prevents fastlane from attempting to update FastlaneRunner swift project')

        c.action do |args, options|
          if ensure_fastfile
            Fastlane::CommandLineHandler.handle(args, options)
          end
        end
      end

      command :init do |c|
        c.syntax = 'fastlane init'
        c.description = 'Helps you with your initial fastlane setup'

        c.option('-u STRING', '--user STRING', String, 'iOS projects only: Your Apple ID')

        c.action do |args, options|
          is_swift_fastfile = args.include?("swift")
          Fastlane::Setup.start(user: options.user, is_swift_fastfile: is_swift_fastfile)
        end
      end

      # Creating alias for mapping "swift init" to "init swift"
      alias_command(:'swift init', :init, 'swift')

      command :new_action do |c|
        c.syntax = 'fastlane new_action'
        c.description = 'Create a new custom action for fastlane.'

        c.option('--name STRING', String, 'Name of your new action')

        c.action do |args, options|
          Fastlane::NewAction.run(new_action_name: options.name)
        end
      end

      command :socket_server do |c|
        c.syntax = 'fastlane start_server'
        c.description = 'Starts local socket server and enables only a single local connection'
        c.option('-s', '--stay_alive', 'Keeps socket server up even after error or disconnects, requires CTRL-C to kill.')
        c.option('-c seconds', '--connection_timeout', 'Sets connection established timeout')
        c.action do |args, options|
          default_connection_timeout = 5
          stay_alive = options.stay_alive || false
          connection_timeout = options.connection_timeout || default_connection_timeout

          if stay_alive && options.connection_timeout.nil?
            UI.important("stay_alive is set, but the connection timeout is not, this will give you #{default_connection_timeout} seconds to (re)connect")
          end

          require 'fastlane/server/socket_server'
          require 'fastlane/server/socket_server_action_command_executor'

          command_executor = SocketServerActionCommandExecutor.new
          server = Fastlane::SocketServer.new(
            command_executor: command_executor,
            connection_timeout: connection_timeout,
            stay_alive: stay_alive
          )
          result = server.start
          UI.success("Result: #{result}") if result
        end
      end

      command :lanes do |c|
        c.syntax = 'fastlane lanes'
        c.description = 'Lists all available lanes and shows their description'
        c.option("-j", "--json", "Output the lanes in JSON instead of text")

        c.action do |args, options|
          if options.json || ensure_fastfile
            require 'fastlane/lane_list'
            path = FastlaneCore::FastlaneFolder.fastfile_path

            if options.json
              Fastlane::LaneList.output_json(path)
            else
              Fastlane::LaneList.output(path)
            end
          end
        end
      end

      command :list do |c|
        c.syntax = 'fastlane list'
        c.description = 'Lists all available lanes without description'
        c.action do |args, options|
          if ensure_fastfile
            ff = Fastlane::FastFile.new(FastlaneCore::FastlaneFolder.fastfile_path)
            UI.message("Available lanes:")
            ff.runner.available_lanes.each do |lane|
              UI.message("- #{lane}")
            end
            UI.important("Execute using `fastlane [lane_name]`")
          end
        end
      end

      command :docs do |c|
        c.syntax = 'fastlane docs'
        c.description = 'Generate a markdown based documentation based on the Fastfile'
        c.option('-f', '--force', 'Overwrite the existing README.md in the ./fastlane folder')

        c.action do |args, options|
          if ensure_fastfile
            ff = Fastlane::FastFile.new(File.join(FastlaneCore::FastlaneFolder.path || '.', 'Fastfile'))
            UI.message("You don't need to run `fastlane docs` manually any more, this will be done automatically for you when running a lane.")
            Fastlane::DocsGenerator.run(ff)
          end
        end
      end

      command :run do |c|
        c.syntax = 'fastlane run [action] key1:value1 key2:value2'
        c.description = 'Run a fastlane one-off action without a full lane'

        c.action do |args, options|
          require 'fastlane/one_off'
          result = Fastlane::OneOff.execute(args: args)
          UI.success("Result: #{result}") if result
        end
      end

      command :actions do |c|
        c.syntax = 'fastlane actions'
        c.description = 'Lists all available fastlane actions'

        c.option('--platform STRING', String, 'Only show actions available on the given platform')

        c.action do |args, options|
          require 'fastlane/documentation/actions_list'
          Fastlane::ActionsList.run(filter: args.first, platform: options.platform)
        end
      end

      command :action do |c|
        c.syntax = 'fastlane action [tool_name]'
        c.description = 'Shows more information for a specific command'
        c.action do |args, options|
          require 'fastlane/documentation/actions_list'
          Fastlane::ActionsList.run(filter: args.first)
        end
      end

      command :enable_auto_complete do |c|
        c.syntax = 'fastlane enable_auto_complete'
        c.description = 'Enable tab auto completion'
        c.option('-c STRING[,STRING2]', '--custom STRING[,STRING2]', String, 'Add custom command(s) for which tab auto complete should be enabled too')

        c.action do |args, options|
          require 'fastlane/auto_complete'
          Fastlane::AutoComplete.execute(args, options)
        end
      end

      command :env do |c|
        c.syntax = 'fastlane env'
        c.description = 'Print your fastlane environment, use this when you submit an issue on GitHub'
        c.action do |args, options|
          require "fastlane/environment_printer"
          Fastlane::EnvironmentPrinter.output
        end
      end

      command :update_fastlane do |c|
        c.syntax = 'fastlane update_fastlane'
        c.description = 'Update fastlane to the latest release'
        c.action do |args, options|
          require 'fastlane/one_off'
          Fastlane::OneOff.run(action: "update_fastlane", parameters: {})
        end
      end

      #####################################################
      # @!group Plugins
      #####################################################

      command :new_plugin do |c|
        c.syntax = 'fastlane new_plugin [plugin_name]'
        c.description = 'Create a new plugin that can be used with fastlane'

        c.action do |args, options|
          PluginGenerator.new.generate(args.shift)
        end
      end

      command :add_plugin do |c|
        c.syntax = 'fastlane add_plugin [plugin_name]'
        c.description = 'Add a new plugin to your fastlane setup'

        c.action do |args, options|
          args << UI.input("Enter the name of the plugin to install: ") if args.empty?
          args.each do |plugin_name|
            Fastlane.plugin_manager.add_dependency(plugin_name)
          end

          UI.important("Make sure to commit your Gemfile, Gemfile.lock and #{PluginManager::PLUGINFILE_NAME} to version control")
          Fastlane.plugin_manager.install_dependencies!
        end
      end

      command :install_plugins do |c|
        c.syntax = 'fastlane install_plugins'
        c.description = 'Install all plugins for this project'

        c.action do |args, options|
          Fastlane.plugin_manager.install_dependencies!
        end
      end

      command :update_plugins do |c|
        c.syntax = 'fastlane update_plugins'
        c.description = 'Update all plugin dependencies'

        c.action do |args, options|
          Fastlane.plugin_manager.update_dependencies!
        end
      end

      command :search_plugins do |c|
        c.syntax = 'fastlane search_plugins [search_query]'
        c.description = 'Search for plugins, search query is optional'

        c.action do |args, options|
          search_query = args.last
          PluginSearch.print_plugins(search_query: search_query)
        end
      end

      default_command(:trigger)
      run!
    end

    # Makes sure a Fastfile is available
    # Shows an appropriate message to the user
    # if that's not the case
    # return true if the Fastfile is available
    def ensure_fastfile
      return true if FastlaneCore::FastlaneFolder.setup?

      create = UI.confirm('Could not find fastlane in current directory. Make sure to have your fastlane configuration files inside a folder called "fastlane". Would you like to set fastlane up?')
      if create
        Fastlane::Setup.start
      end
      return false
    end
  end
end
