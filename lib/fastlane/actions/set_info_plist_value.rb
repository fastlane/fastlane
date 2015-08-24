module Fastlane
  module Actions
    module SharedValues
      SET_INFO_PLIST_VALUE_CUSTOM_VALUE = :SET_INFO_PLIST_VALUE_CUSTOM_VALUE
    end

    class SetInfoPlistValueAction < Action
      def self.run(params)
      require "plist"
        begin
          path = File.expand_path(params[:plist_path])
	      plist = Plist::parse_xml(path)
	      plist[params[:param_name]] = params[:param_value]
	      new_plist = plist.to_plist
	      File.open(path, 'w') { |file| file.write(new_plist) }
        rescue
          Helper.log.info "Unable to set value to plist file at #{path}".red
        end
	  end

      def self.description
        "Sets value to Info.plist of your project as native Ruby data structures"
      end

      def self.available_options

        [
 		  FastlaneCore::ConfigItem.new(key: :param_name,
                                       env_name: "FL_SET_INFO_PLIST_PARAM_NAME",
                                       description: "Name of parameter",
                                       optional: false),
 		  FastlaneCore::ConfigItem.new(key: :param_value,
                                       env_name: "FL_SET_INFO_PLIST_PARAM_VALUE",
                                       description: "Name of parameter",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :plist_path,
                                       env_name: "FL_SET_INFO_PLIST_PATH",
                                       description: "Path to Info.plist",
                                       optional: false)
        ]
      end

      def self.output
        [ ]
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