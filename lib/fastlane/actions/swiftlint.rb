module Fastlane
  module Actions
    class SwiftlintAction < Action
      def self.run(params)
        if `which swiftlint`.to_s.length == 0 and !Helper.test?
          raise "You have to install swiftlint using `brew install swiftlint`".red
        end

        command_prefix = [
          'cd',
          File.expand_path('.').shellescape,
          '&&'
        ].join(' ')
        swiftlint_args = params[:report_file] ? "> #{params[:report_file]}" : ""

        command = [
          command_prefix,
          'swiftlint',
          swiftlint_args
        ].join(' ')

        Action.sh command
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
          FastlaneCore::ConfigItem.new(key: :report_file,
                                        env_name: "FL_SWIFTLINT_REPORT_FILE",
                                        description: "Specifies a file where swiftlint output is piped to",
                                        optional: true)
        ]
      end

      def self.output
      end

      def self.return_value
        "Returns error status code if serious violations found, zero otherwise"
      end

      def self.authors
        ["KrauseFx", "c_Gretzki"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
