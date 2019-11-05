module Fastlane
  module Actions
    class ShAction < Action
      def self.run(params)
        # this is implemented in the sh_helper.rb
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Runs a shell command"
      end

      def self.details
        [
          "Allows running an arbitrary shell command.",
          "Be aware of a specific behavior of `sh` action with regard to the working directory. For details, refer to [Advanced](https://docs.fastlane.tools/advanced/#directory-behavior)."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :command,
                                         description: 'Shell command to be executed',
                                         optional: false,
                                         is_string: true),
          FastlaneCore::ConfigItem.new(key: :log,
                                         description: 'Determines whether fastlane should print out the executed command itself and output of the executed command. If command line option --troubleshoot is used, then it overrides this option to true',
                                         optional: true,
                                         is_string: false,
                                         default_value: true),
          FastlaneCore::ConfigItem.new(key: :error_callback,
                                         description: 'A callback invoked with the command output if there is a non-zero exit status',
                                         optional: true,
                                         is_string: false,
                                         type: :string_callback,
                                         default_value: nil)
        ]
      end

      def self.return_value
        'Outputs the string and executes it. When running in tests, it returns the actual command instead of executing it'
      end

      def self.return_type
        :string
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'sh("ls")',
          'sh("git", "commit", "-m", "My message")'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
