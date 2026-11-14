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
                                         optional: false),
          FastlaneCore::ConfigItem.new(key: :log,
                                         description: 'Determines whether fastlane should print out the executed command itself and output of the executed command. If command line option --troubleshoot is used, then it overrides this option to true',
                                         optional: true,
                                         type: Boolean,
                                         default_value: true),
          FastlaneCore::ConfigItem.new(key: :error_callback,
                                         description: 'A callback invoked with the command output if there is a non-zero exit status',
                                         optional: true,
                                         type: :string_callback,
                                         default_value: nil),
          FastlaneCore::ConfigItem.new(key: :stdin,
                                         description: 'Data written to the command\'s standard input, which is then closed. It is never printed, so it can carry a secret the command reads from its input',
                                         optional: true,
                                         sensitive: true,
                                         type: String,
                                         default_value: nil),
          FastlaneCore::ConfigItem.new(key: :chdir,
                                         description: 'Directory the command runs in; the lane\'s own directory stays as it is',
                                         optional: true,
                                         type: String,
                                         default_value: nil),
          FastlaneCore::ConfigItem.new(key: :separate_stderr,
                                         description: 'Return stdout only; stderr goes to the error message and the error_callback',
                                         optional: true,
                                         type: Boolean,
                                         default_value: false)
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
          'sh("git", "commit", "-m", "My message")',
          'sh("gh", "auth", "login", "--with-token", stdin: ENV["GH_TOKEN"])',
          'version = sh("xcodebuild", "-version", separate_stderr: true)'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
