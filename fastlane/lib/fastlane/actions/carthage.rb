module Fastlane
  module Actions
    class CarthageAction < Action
      # rubocop:disable Metrics/PerceivedComplexity
      def self.run(params)
        validate(params)

        cmd = [params[:executable]]
        command_name = params[:command]
        cmd << command_name

        if command_name == "archive" && params[:frameworks].count > 0
          cmd.concat(params[:frameworks])
        elsif ["update", "build", "bootstrap"].include?(command_name) && params[:dependencies].count > 0
          cmd.concat(params[:dependencies])
        end

        cmd << "--output #{params[:output]}" if params[:output]
        cmd << "--use-ssh" if params[:use_ssh]
        cmd << "--use-submodules" if params[:use_submodules]
        cmd << "--no-use-binaries" if params[:use_binaries] == false
        cmd << "--no-build" if params[:no_build] == true
        cmd << "--no-skip-current" if params[:no_skip_current] == true
        cmd << "--verbose" if params[:verbose] == true
        cmd << "--platform #{params[:platform]}" if params[:platform]
        cmd << "--configuration #{params[:configuration]}" if params[:configuration]
        cmd << "--derived-data #{params[:derived_data].shellescape}" if params[:derived_data]
        cmd << "--toolchain #{params[:toolchain]}" if params[:toolchain]
        cmd << "--project-directory #{params[:project_directory]}" if params[:project_directory]
        cmd << "--cache-builds" if params[:cache_builds]
        cmd << "--new-resolver" if params[:new_resolver]
        cmd << "--log-path #{params[:log_path]}" if params[:log_path]

        Actions.sh(cmd.join(' '))
      end
      # rubocop:enable Metrics/PerceivedComplexity

      def self.validate(params)
        command_name = params[:command]
        if command_name != "archive" && params[:frameworks].count > 0
          UI.user_error!("Frameworks option is available only for 'archive' command.")
        end
        if command_name != "archive" && params[:output]
          UI.user_error!("Output option is available only for 'archive' command.")
        end

        if params[:log_path] && !%w(build bootstrap update).include?(command_name)
          UI.user_error!("Log path option is available only for 'build', 'bootstrap', and 'update' command.")
        end
      end

      def self.description
        "Runs `carthage` for your project"
      end

      def self.available_commands
        %w(build bootstrap update archive)
      end

      def self.available_platforms
        %w(all iOS Mac tvOS watchOS)
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :command,
                                       env_name: "FL_CARTHAGE_COMMAND",
                                       description: "Carthage command (one of: #{available_commands.join(', ')})",
                                       default_value: 'bootstrap',
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a valid command. Use one of the following: #{available_commands.join(', ')}") unless available_commands.include?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :dependencies,
                                       description: "Carthage dependencies to update, build or bootstrap",
                                       default_value: [],
                                       is_string: false,
                                       type: Array),
          FastlaneCore::ConfigItem.new(key: :use_ssh,
                                       env_name: "FL_CARTHAGE_USE_SSH",
                                       description: "Use SSH for downloading GitHub repositories",
                                       is_string: false,
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :use_submodules,
                                       env_name: "FL_CARTHAGE_USE_SUBMODULES",
                                       description: "Add dependencies as Git submodules",
                                       is_string: false,
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :use_binaries,
                                       env_name: "FL_CARTHAGE_USE_BINARIES",
                                       description: "Check out dependency repositories even when prebuilt frameworks exist",
                                       is_string: false,
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :no_build,
                                       env_name: "FL_CARTHAGE_NO_BUILD",
                                       description: "When bootstrapping Carthage do not build",
                                       is_string: false,
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :no_skip_current,
                                       env_name: "FL_CARTHAGE_NO_SKIP_CURRENT",
                                       description: "Don't skip building the Carthage project (in addition to its dependencies)",
                                       is_string: false,
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :derived_data,
                                       env_name: "FL_CARTHAGE_DERIVED_DATA",
                                       description: "Use derived data folder at path",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_CARTHAGE_VERBOSE",
                                       description: "Print xcodebuild output inline",
                                       is_string: false,
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :platform,
                                       env_name: "FL_CARTHAGE_PLATFORM",
                                       description: "Define which platform to build for",
                                       optional: true,
                                       verify_block: proc do |value|
                                         value.split(',').each do |platform|
                                           UI.user_error!("Please pass a valid platform. Use one of the following: #{available_platforms.join(', ')}") unless available_platforms.map(&:downcase).include?(platform.downcase)
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :cache_builds,
                                       env_name: "FL_CARTHAGE_CACHE_BUILDS",
                                       description: "By default Carthage will rebuild a dependency regardless of whether it's the same resolved version as before. Passing the --cache-builds will cause carthage to avoid rebuilding a dependency if it can",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :frameworks,
                                       description: "Framework name or names to archive, could be applied only along with the archive command",
                                       default_value: [],
                                       is_string: false,
                                       type: Array),
          FastlaneCore::ConfigItem.new(key: :output,
                                       description: "Output name for the archive, could be applied only along with the archive command. Use following format *.framework.zip",
                                       is_string: true,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a valid string for output. Use following format *.framework.zip") unless value.end_with?("framework.zip")
                                       end),
          FastlaneCore::ConfigItem.new(key: :configuration,
                                       env_name: "FL_CARTHAGE_CONFIGURATION",
                                       description: "Define which build configuration to use when building",
                                       optional: true,
                                       verify_block: proc do |value|
                                         if value.chomp(' ').empty?
                                           UI.user_error!("Please pass a valid build configuration. You can review the list of configurations for this project using the command: xcodebuild -list")
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :toolchain,
                                       env_name: "FL_CARTHAGE_TOOLCHAIN",
                                       description: "Define which xcodebuild toolchain to use when building",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :project_directory,
                                       env_name: "FL_CARTHAGE_PROJECT_DIRECTORY",
                                       description: "Define the directory containing the Carthage project",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :new_resolver,
                                       env_name: "FL_CARTHAGE_NEW_RESOLVER",
                                       description: "Use new resolver when resolving dependency graph",
                                       is_string: false,
                                       optional: true,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :log_path,
                                       env_name: "FL_CARTHAGE_LOG_PATH",
                                       description: "Path to the xcode build output",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :executable,
                                       env_name: "FL_CARTHAGE_EXECUTABLE",
                                       description: "Path to the `carthage` executable on your machine",
                                       default_value: 'carthage')
        ]
      end

      def self.example_code
        [
          'carthage',
          'carthage(
            frameworks: ["MyFramework1", "MyFramework2"],   # Specify which frameworks to archive (only for the archive command)
            output: "MyFrameworkBundle.framework.zip",      # Specify the output archive name (only for the archive command)
            command: "bootstrap",                           # One of: build, bootstrap, update, archive. (default: bootstrap)
            dependencies: ["Alamofire", "Notice"],          # Specify which dependencies to update or build (only for update, build and bootstrap commands)
            use_ssh: false,                                 # Use SSH for downloading GitHub repositories.
            use_submodules: false,                          # Add dependencies as Git submodules.
            use_binaries: true,                             # Check out dependency repositories even when prebuilt frameworks exist
            no_build: false,                                # When bootstrapping Carthage do not build
            no_skip_current: false,                         # Don\'t skip building the current project (only for frameworks)
            verbose: false,                                 # Print xcodebuild output inline
            platform: "all",                                # Define which platform to build for (one of ‘all’, ‘Mac’, ‘iOS’, ‘watchOS’, ‘tvOS‘, or comma-separated values of the formers except for ‘all’)
            configuration: "Release",                       # Build configuration to use when building
            cache_builds: true,                             # By default Carthage will rebuild a dependency regardless of whether its the same resolved version as before.
            toolchain: "com.apple.dt.toolchain.Swift_2_3",  # Specify the xcodebuild toolchain
            new_resolver: false,                            # Use the new resolver to resolve depdendency graph
            log_path: "carthage.log"                        # Path to the xcode build output
          )'
        ]
      end

      def self.category
        :building
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.authors
        ["bassrock", "petester42", "jschmid", "JaviSoto", "uny", "phatblat", "bfcrampton", "antondomashnev", "gbrhaz"]
      end
    end
  end
end
