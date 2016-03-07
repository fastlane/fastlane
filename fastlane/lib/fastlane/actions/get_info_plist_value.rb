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
          plist = Plist.parse_xml(path)

          value = plist[params[:key]]
          Actions.lane_context[SharedValues::GET_INFO_PLIST_VALUE_CUSTOM_VALUE] = value

          return value
        rescue => ex
          Helper.log.error ex
          Helper.log.error "Unable to find plist file at '#{path}'".red
        end
      end

      def self.description
        "Returns value from Info.plist of your project as native Ruby data structures"
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
                                         raise "Couldn't find plist file at path '#{value}'".red unless File.exist?(value)
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
        [:ios, :mac].include? platform
      end
    end
  end
end
