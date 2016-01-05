module Fastlane
  module Actions
    class SwiftlintAction < Action
      def self.run(params)
        if `which swiftlint`.to_s.length == 0 and !Helper.test?
          raise "You have to install swiftlint using `brew install swiftlint`".red
        end

        command = 'swiftlint lint'
        command << " --config #{params[:config_file]}" if params[:config_file]
        command << " > #{params[:output_file]}" if params[:output_file]
        Actions.sh(command)
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
          FastlaneCore::ConfigItem.new(key: :output_file,
                                       description: 'Path to output SwiftLint result',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :config_file,
                                       description: 'Custom configuration file of SwiftLint',
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
    end
  end
end
