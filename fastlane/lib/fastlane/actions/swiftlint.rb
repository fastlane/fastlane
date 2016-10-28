module Fastlane
  module Actions
    class SwiftlintAction < Action
      def self.run(params)
        if `which swiftlint`.to_s.length == 0 and !Helper.test?
          UI.user_error!("You have to install swiftlint using `brew install swiftlint`")
        end

        version = Gem::Version.new(Helper.test? ? '0.0.0' : `swiftlint version`.chomp)
        if params[:mode] == :autocorrect and version < Gem::Version.new('0.5.0') and !Helper.test?
          UI.user_error!("Your version of swiftlint (#{version}) does not support autocorrect mode.\nUpdate swiftlint using `brew update && brew upgrade swiftlint`")
        end

        command = "swiftlint #{params[:mode]}"
        command << " --strict" if params[:strict]
        command << " --config #{params[:config_file].shellescape}" if params[:config_file]

        if params[:files]
          if version < Gem::Version.new('0.5.1') and !Helper.test?
            UI.user_error!("Your version of swiftlint (#{version}) does not support list of files as input.\nUpdate swiftlint using `brew update && brew upgrade swiftlint`")
          end

          files = params[:files].map.with_index(0) { |f, i| "SCRIPT_INPUT_FILE_#{i}=#{f.shellescape}" }.join(" ")
          command = command.prepend("SCRIPT_INPUT_FILE_COUNT=#{params[:files].count} #{files} ")
          command << " --use-script-input-files"
        end

        command << " > #{params[:output_file].shellescape}" if params[:output_file]

        begin
          Actions.sh(command)
        rescue
          handle_swiftlint_error(params[:ignore_exit_status], $?.exitstatus)
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Run swift code validation using SwiftLint"
      end

      def self.details
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :mode,
                                       description: "SwiftLint mode: :lint (default) or :autocorrect; default is :lint",
                                       is_string: false,
                                       default_value: :lint,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :output_file,
                                       description: 'Path to output SwiftLint result',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :config_file,
                                       description: 'Custom configuration file of SwiftLint',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :strict,
                                       description: 'Fail on warnings? (true/false)',
                                       default_value: false,
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :files,
                                       description: 'List of files to process',
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :ignore_exit_status,
                                       description: "Ignore the exit status of the SwiftLint command, so that serious violations \
                                                    don't fail the build (true/false)",
                                       default_value: false,
                                       is_string: false,
                                       optional: true)
        ]
      end

      def self.output
      end

      def self.return_value
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'swiftlint(
            mode: :lint,                          # SwiftLint mode: :lint (default) or :autocorrect
            output_file: "swiftlint.result.json", # The path of the output file (optional)
            config_file: ".swiftlint-ci.yml",     # The path of the configuration file (optional)
            files: [                              # List of files to process (optional)
              "AppDelegate.swift",
              "path/to/project/Model.swift"
            ],
            ignore_exit_status: true              # Allow fastlane to continue even if SwiftLint returns a non-zero exit status
          )'
        ]
      end

      def self.category
        :testing
      end

      def self.handle_swiftlint_error(ignore_exit_status, exit_status)
        if ignore_exit_status
          failure_suffix = 'which would normally fail the build.'
          secondary_message = 'fastlane will continue because the `ignore_exit_status` option was used! 🙈'
        else
          failure_suffix = 'which represents a failure.'
          secondary_message = 'If you want fastlane to continue anyway, use the `ignore_exit_status` option. 🙈'
        end

        UI.important("")
        UI.important("SwiftLint finished with exit code #{exit_status}, #{failure_suffix}")
        UI.important(secondary_message)
        UI.important("")
        UI.user_error!("SwiftLint finished with errors (exit code: #{exit_status})") unless ignore_exit_status
      end
    end
  end
end
