module Fastlane
  module Actions
    class JazzyAction < Action
      def self.run(params)
        Actions.verify_gem!('jazzy')
        command = "jazzy"
        command << " --config #{params[:config]}" if params[:config]
        command << " --module-version #{params[:module_version]}" if params[:module_version]
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
          FastlaneCore::ConfigItem.new(key: :config,
                                       env_name: 'FL_JAZZY_CONFIG',
                                       description: 'Path to jazzy config file',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :module_version,
                                       env_name: 'FL_JAZZY_MODULE_VERSION',
                                       description: 'Version string to use as part of the default docs title and inside the docset',
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
          'jazzy',
          'jazzy(config: ".jazzy.yaml", module_version: "2.1.37")'
        ]
      end

      def self.category
        :documentation
      end
    end
  end
end
