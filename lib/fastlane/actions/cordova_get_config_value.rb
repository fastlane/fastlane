module Fastlane
  module Actions
    module SharedValues
      CORDOVA_GET_CONFIG_VALUE_CUSTOM_VALUE = :CORDOVA_GET_CONFIG_VALUE_CUSTOM_VALUE
    end

    class CordovaGetConfigValueAction < Action
      def self.run(params)
        Actions.verify_gem!('xml-simple')
        require 'xmlsimple'
        begin
          config_file = File.open(File.expand_path(params[:path]))
          config = XmlSimple.xml_in(config_file)

          value = config[params[:key]]
          Actions.lane_context[SharedValues::CORDOVA_GET_CONFIG_VALUE_CUSTOM_VALUE] = value

          return value
        rescue => ex
          Helper.log.error ex
          Helper.log.error "Unable to find config file at '#{path}'".red
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Returns value from config.xml of your cordova project as native Ruby data structures"
      end

      def self.details
        # Optional:
        # this is your change to provide a more detailed description of this action
        "You can use this action to do cool things..."
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
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
        # Define the shared values you are going to provide
        # Example
        [
          ['CORDOVA_GET_CONFIG_VALUE_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If you method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["platanus", "blackjid"]
      end

      def self.is_supported?(platform)
        # you can do things like
        #
        #  true
        #
        #  platform == :ios
        #
        #  [:ios, :mac].include?(platform)
        #

        platform == :ios
      end
    end
  end
end
