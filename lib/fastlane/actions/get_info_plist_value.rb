module Fastlane
  module Actions
    module SharedValues
      GET_INFO_PLIST_VALUE_CUSTOM_VALUE = :GET_INFO_PLIST_VALUE_CUSTOM_VALUE
    end

    class GetInfoPlistValueAction < Action
      def self.run(params)
        require "plist"
        begin
          path = File.expand_path(params[:plist_path])
	      plist = Plist::parse_xml(path)
 	      Actions.lane_context[SharedValues::INFO_PLIST_VALUE] = plist[params[:param_name]]
        rescue
          Helper.log.info "Unable to find plist file at #{path}".red
 	    end
      end

      def self.description
        "returns value from Info.plist of your project as native Ruby data structures"
      end

      def self.available_options
        [
		  FastlaneCore::ConfigItem.new(key: :param_name,
                                       env_name: "FL_GET_INFO_PLIST_PARAM_NAME",
                                       description: "Name of parameter",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :plist_path,
                                       env_name: "FL_GET_INFO_PLIST_PATH",
                                       description: "Path to Info.plist",
                                       optional: false)
        ]
      end

      def self.output
        [
          ['GET_INFO_PLIST_VALUE_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.authors
        ["kohtenko"]
      end

      def self.is_supported?(platform)
	    [:ios, :mac].include?platform
      end
    end
  end
end