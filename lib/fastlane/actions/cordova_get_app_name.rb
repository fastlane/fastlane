module Fastlane
  module Actions
    module SharedValues
      CORDOVA_APP_NAME = :CORDOVA_APP_NAME
    end

    class CordovaGetAppNameAction < Action
      def self.run(params)
        require 'rexml/document'

        config_file = File.open(File.expand_path(params[:path]))
        config = REXML::Document.new(config_file)

        value = config.elements['widget'].elements['name'].first.value

        Actions.lane_context[SharedValues::CORDOVA_APP_NAME] = value
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Returns the app name defined in the cordova configuration file"
      end

      def self.details
        "This action let to get from the cordova config.xml the value of" \
        "the name tag"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "CORDOVA_CONFIG_PATH",
                                       description: "Path to config file you want to read",
                                       optional: true,
                                       default_value: './config.xml',
                                       verify_block: proc do |value|
                                         unless File.exist?(File.expand_path(value))
                                           raise "Couldn't find config file at path '#{value}'".red
                                         end
                                       end)
        ]
      end

      def self.output
        [
          ['CORDOVA_APP_NAME', 'Cordova App Name']
        ]
      end

      def self.return_value
        # If you method provides a return value, you can describe here what it does
      end

      def self.authors
        ["platanus", "blackjid"]
      end

      # rubocop:disable Style/PredicateName
      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end
      # rubocop:enable Style/PredicateName
    end
  end
end
