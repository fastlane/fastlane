module Fastlane
  module Actions
    module SharedValues
      CORDOVA_APP_ID = :CORDOVA_APP_ID
    end

    class CordovaGetAppIdAction < Action
      def self.run(params)
        require 'rexml/document'

        config_file = File.open(File.expand_path(params[:path]))
        config = REXML::Document.new(config_file)

        id_key = case params[:platform]
                 when :ios
                   'ios-CFBundleIdentifier'
                 when :android
                   'android-packageName'
                 else
                   'id'
                 end

        value = config.elements['widget'].attributes[id_key]
        value = config.elements['widget'].attributes['id'] if value.nil?

        Actions.lane_context[SharedValues::CORDOVA_APP_ID] = value
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Returns the app id defined in the cordova configuration file"
      end

      def self.details
        "This action let to get from the cordova config.xml the value of" \
        "the id attribute from the widget tag"
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
                                       end),
          FastlaneCore::ConfigItem.new(key: :platform,
                                      description: "Look for the specific plarform id",
                                      is_string: false,
                                      optional: true,
                                      default_value: nil)
        ]
      end

      def self.output
        [
          ['CORDOVA_APP_ID', 'Cordova App ID']
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
