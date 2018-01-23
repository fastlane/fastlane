module Fastlane
  module Actions
    module SharedValues
      GET_INFO_PLIST_VALUE_CUSTOM_VALUE = :GET_INFO_PLIST_VALUE_CUSTOM_VALUE
    end

    class GetInfoPlistValueAction < Action
      def self.run(params)
        require "plist"

        begin
          path = File.expand_path(params[:path])

          plist = File.open(path) { |f| Plist.parse_xml(f) }

          value = plist[params[:key]]
          Actions.lane_context[SharedValues::GET_INFO_PLIST_VALUE_CUSTOM_VALUE] = value

          return value
        rescue => ex
          UI.error(ex)
        end
      end

      def self.description
        "Returns value from Info.plist of your project as native Ruby data structures"
      end

      def self.details
        "Get a value from a plist file, which can be used to fetch the app identifier and more information about your app"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :key,
                                       env_name: "FL_GET_INFO_PLIST_PARAM_NAME",
                                       description: "Name of parameter",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_GET_INFO_PLIST_PATH",
                                       description: "Path to plist file you want to read",
                                       optional: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find plist file at path '#{value}'") unless File.exist?(value)
                                       end)
        ]
      end

      def self.output
        [
          ['GET_INFO_PLIST_VALUE_CUSTOM_VALUE', 'The value of the last plist file that was parsed']
        ]
      end

      def self.authors
        ["kohtenko"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'identifier = get_info_plist_value(path: "./Info.plist", key: "CFBundleIdentifier")'
        ]
      end

      def self.return_type
        :string
      end

      def self.category
        :project
      end
    end
  end
end
