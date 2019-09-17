module Fastlane
  module Actions
    class SwiftlintAction < Action
      def self.run(params)
        if `which swiftlint`.to_s.length == 0 && params[:executable].nil? && !Helper.test?
          UI.user_error!("You have to install swiftlint using `brew install swiftlint` or specify the executable path with the `:executable` option.")
        end

        version = swiftlint_version(executable: params[:executable])
        if params[:mode] == :autocorrect && version < Gem::Version.new('0.5.0') && !Helper.test?
          UI.user_error!("Your version of swiftlint (#{version}) does not support autocorrect mode.\nUpdate swiftlint using `brew update && brew upgrade swiftlint`")
        end

        command = (params[:executable] || "swiftlint").dup
        command << " #{params[:mode]}"
        command << " --path #{params[:path].shellescape}" if params[:path]
        command << supported_option_switch(params, :strict, "0.9.2", true)
        command << " --config #{params[:config_file].shellescape}" if params[:config_file]
        command << " --reporter #{params[:reporter]}" if params[:reporter]
        command << supported_option_switch(params, :quiet, "0.9.0", true)
        command << supported_option_switch(params, :format, "0.11.0", true) if params[:mode] == :autocorrect
        command << " --compiler-log-path #{params[:compiler_log_path].shellescape}" if params[:compiler_log_path]

        if params[:files]
          if version < Gem::Version.new('0.5.1')
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

      # Get current SwiftLint version
      def self.swiftlint_version(executable: nil)
        binary = executable || 'swiftlint'
        Gem::Version.new(`#{binary} version`.chomp)
      end

      # Return "--option" switch if option is on and current SwiftLint version is greater or equal than min version.
      # Return "" otherwise.
      def self.supported_option_switch(params, option, min_version, can_ignore = false)
        return "" unless params[option]
        version = swiftlint_version(executable: params[:executable])
        if version < Gem::Version.new(min_version)
          message = "Your version of swiftlint (#{version}) does not support '--#{option}' option.\nUpdate swiftlint to #{min_version} or above using `brew update && brew upgrade swiftlint`"
          message += "\nThe option will be ignored." if can_ignore
          can_ignore ? UI.important(message) : UI.user_error!(message)
          ""
        else
          " --#{option}"
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Run swift code validation using SwiftLint"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :mode,
                                       description: "SwiftLint mode: :lint, :autocorrect or :analyze",
                                       is_string: false,
                                       default_value: :lint,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :path,
                                       description: "Specify path to lint",
                                       is_string: true,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find path '#{File.expand_path(value)}'") unless File.exist?(value)
                                       end),
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
                                       type: Boolean,
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
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :reporter,
                                       description: 'Choose output reporter',
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :quiet,
                                       description: "Don't print status logs like 'Linting <file>' & 'Done linting'",
                                       default_value: false,
                                       is_string: false,
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :executable,
                                       description: "Path to the `swiftlint` executable on your machine",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :format,
                                       description: "Format code when mode is :autocorrect",
                                       default_value: false,
                                       is_string: false,
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :compiler_log_path,
                                       description: "Compiler log path when mode is :analyze",
                                       is_string: true,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find compiler_log_path '#{File.expand_path(value)}'") unless File.exist?(value)
                                       end)
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
            path: "/path/to/lint",                 # Specify path to lint (optional)
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
