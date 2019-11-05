module Fastlane
  module Actions
    class JazzyAction < Action
      def self.run(params)
        Actions.verify_gem!('jazzy')
        command = "jazzy"
        command << " --config #{params[:config]}" if params[:config]
        Actions.sh(command)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Generate docs using Jazzy"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :config,
            env_name: 'FL_JAZZY_CONFIG',
            description: 'Path to jazzy config file',
            is_string: true,
            optional: true
          )
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
          'jazzy'
        ]
      end

      def self.category
        :documentation
      end
    end
  end
end
