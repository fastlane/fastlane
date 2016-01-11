module Fastlane
  module Actions
    module SharedValues
      CORDOVA_GET_CONFIG_VALUE_CUSTOM_VALUE = :CORDOVA_GET_CONFIG_VALUE_CUSTOM_VALUE
    end

    class CordovaGetConfigValueAction < Action
      def self.run(params)
        Actions.verify_gem!('xml-simple')
        require 'xmlsimple'

        config_file = File.open(File.expand_path(params[:path]))
        config = XmlSimple.xml_in(config_file)

        value = config[params[:key]]
        Actions.lane_context[SharedValues::CORDOVA_GET_CONFIG_VALUE_CUSTOM_VALUE] = value

        return value
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Returns value from config.xml of your cordova project"
      end

      def self.details
        "This action let to get any value from the config.xml file. It will return a ruby object you can use."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :key,
                                       env_name: "CORDOVA_GET_CONFIG_PARAM_NAME",
                                       description: "Name of parameter",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "CORDOVA_GET_CONFIG_PATH",
                                       description: "Path to config file you want to read",
                                       optional: true,
                                       default_value: './config.xml',
                                       verify_block: proc do |value|
                                         path = File.expand_path(value)
                                         raise "Couldn't find config file at path '#{value}'".red unless File.exist?(path)
                                       end)
        ]
      end

      def self.output
        [
          ['CORDOVA_GET_CONFIG_VALUE_CUSTOM_VALUE', 'Value for the key required from the config.xml file']
        ]
      end

      def self.return_value
        # If you method provides a return value, you can describe here what it does
      end

      def self.authors
        ["platanus", "blackjid"]
      end

      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end
    end
  end
end
