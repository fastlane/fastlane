module Fastlane
  module Actions
    class CarthageAction < Action
      def self.run(params)
        cmd = ["carthage"]

        cmd << params[:command]

        if params[:command] == "update" && params[:dependencies].count > 0
          cmd.concat params[:dependencies]
        end

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

        Actions.sh(cmd.join(' '))
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
                                         UI.user_error!("Please pass a valid command. Use one of the following: #{available_commands.join(', ')}") unless available_commands.include? value
                                       end),
          FastlaneCore::ConfigItem.new(key: :dependencies,
                                       description: "Carthage dependencies to update",
                                       default_value: [],
                                       is_string: false,
                                       type: Array),
          FastlaneCore::ConfigItem.new(key: :use_ssh,
                                       env_name: "FL_CARTHAGE_USE_SSH",
                                       description: "Use SSH for downloading GitHub repositories",
                                       is_string: false,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a valid value for use_ssh. Use one of the following: true, false") unless value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
                                       end),
          FastlaneCore::ConfigItem.new(key: :use_submodules,
                                       env_name: "FL_CARTHAGE_USE_SUBMODULES",
                                       description: "Add dependencies as Git submodules",
                                       is_string: false,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a valid value for use_submodules. Use one of the following: true, false") unless value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
                                       end),
          FastlaneCore::ConfigItem.new(key: :use_binaries,
                                       env_name: "FL_CARTHAGE_USE_BINARIES",
                                       description: "Check out dependency repositories even when prebuilt frameworks exist",
                                       is_string: false,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a valid value for use_binaries. Use one of the following: true, false") unless value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
                                       end),
          FastlaneCore::ConfigItem.new(key: :no_build,
                                       env_name: "FL_CARTHAGE_NO_BUILD",
                                       description: "When bootstrapping Carthage do not build",
                                       is_string: false,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a valid value for no_build. Use one of the following: true, false") unless value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
                                       end),
          FastlaneCore::ConfigItem.new(key: :no_skip_current,
                                       env_name: "FL_CARTHAGE_NO_SKIP_CURRENT",
                                       description: "Don't skip building the Carthage project (in addition to its dependencies)",
                                       is_string: false,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a valid value for no_skip_current. Use one of the following: true, false") unless value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
                                       end),
          FastlaneCore::ConfigItem.new(key: :derived_data,
                                       env_name: "FL_CARTHAGE_DERIVED_DATA",
                                       description: "Use derived data folder at path",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_CARTHAGE_VERBOSE",
                                       description: "Print xcodebuild output inline",
                                       is_string: false,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a valid value for verbose. Use one of the following: true, false") unless value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
                                       end),
          FastlaneCore::ConfigItem.new(key: :platform,
                                       env_name: "FL_CARTHAGE_PLATFORM",
                                       description: "Define which platform to build for",
                                       optional: true,
                                       verify_block: proc do |value|
                                         value.split(',').each do |platform|
                                           UI.user_error!("Please pass a valid platform. Use one of the following: #{available_platforms.join(', ')}") unless available_platforms.map(&:downcase).include?(platform.downcase)
                                         end
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
                                       optional: true)
        ]
      end

      def self.example_code
        [
          'carthage',
          'carthage(
            command: "bootstrap",                           # One of: build, bootstrap, update, archive. (default: bootstrap)
            dependencies: ["Alamofire", "Notice"],          # Specify which dependencies to update (only for the update command)
            use_ssh: false,                                 # Use SSH for downloading GitHub repositories.
            use_submodules: false,                          # Add dependencies as Git submodules.
            use_binaries: true,                             # Check out dependency repositories even when prebuilt frameworks exist
            no_build: false,                                # When bootstrapping Carthage do not build
            no_skip_current: false,                         # Don\'t skip building the current project (only for frameworks)
            verbose: false,                                 # Print xcodebuild output inline
            platform: "all",                                # Define which platform to build for (one of ‘all’, ‘Mac’, ‘iOS’, ‘watchOS’, ‘tvOS‘, or comma-separated values of the formers except for ‘all’)
            configuration: "Release",                       # Build configuration to use when building
            toolchain: "com.apple.dt.toolchain.Swift_2_3"   # Specify the xcodebuild toolchain
          )'
        ]
      end

      def self.category
        :building
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end

      def self.authors
        ["bassrock", "petester42", "jschmid", "JaviSoto", "uny", "phatblat", "bfcrampton"]
      end
    end
  end
end
