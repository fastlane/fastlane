module Fastlane
  module Actions
    class SpmAction < Action
      def self.run(params)
        cmd = ["swift"]

        cmd << (package_commands.include?(params[:command]) ? "package" : params[:command])
        cmd << "--build-path #{params[:build_path]}" if params[:build_path]
        cmd << "--package-path #{params[:package_path]}" if params[:package_path]
        cmd << "--configuration #{params[:configuration]}" if params[:configuration]
        cmd << "--verbose" if params[:verbose]
        if params[:xcpretty_output]
          cmd += ["2>&1", "|", "xcpretty", "--#{params[:xcpretty_output]}"]
          cmd = %w(set -o pipefail &&) + cmd
        end
        cmd << params[:command] if package_commands.include?(params[:command])

        FastlaneCore::CommandExecutor.execute(command: cmd.join(" "),
                                              print_all: true,
                                              print_command: true)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Runs Swift Package Manager on your project"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :command,
                                       env_name: "FL_SPM_COMMAND",
                                       description: "The swift command (one of: #{available_commands.join(', ')})",
                                       default_value: "build",
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a valid command. Use one of the following: #{available_commands.join(', ')}") unless available_commands.include?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :build_path,
                                       env_name: "FL_SPM_BUILD_PATH",
                                       description: "Specify build/cache directory [default: ./.build]",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :package_path,
                                       env_name: "FL_SPM_PACKAGE_PATH",
                                       description: "Change working directory before any other operation",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :configuration,
                                       short_option: "-c",
                                       env_name: "FL_SPM_CONFIGURATION",
                                       description: "Build with configuration (debug|release) [default: debug]",
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a valid configuration: (debug|release)") unless valid_configurations.include?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :xcpretty_output,
                                       env_name: "FL_SPM_XCPRETTY_OUTPUT",
                                       description: "Specifies the output type for xcpretty. eg. 'test', or 'simple'",
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Please pass a valid xcpretty output type: (#{xcpretty_output_types.join('|')})") unless xcpretty_output_types.include?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       short_option: "-v",
                                       env_name: "FL_SPM_VERBOSE",
                                       description: "Increase verbosity of informational output",
                                       is_string: false,
                                       default_value: false)
        ]
      end

      def self.authors
        ["Flávio Caetano (@fjcaetano)"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'spm',
          'spm(
            command: "build",
            build_path: "./build",
            configuration: "release"
          )'
        ]
      end

      def self.category
        :building
      end

      def self.available_commands
        %w(build test) + self.package_commands
      end

      def self.package_commands
        %w(clean reset update)
      end

      def self.valid_configurations
        %w(debug release)
      end

      def self.xcpretty_output_types
        %w(simple test knock tap)
      end
    end
  end
end
