module Fastlane
  module Actions
    module SharedValues
    end

    class SetInfoPlistValueAction < Action
      def self.run(params)
        require "plist"

        begin
          path = File.expand_path(params[:path])
          plist = Plist.parse_xml(path)
          plist[params[:key]] = params[:value]
          new_plist = Plist::Emit.dump(plist)
          File.write(path, new_plist)

          return params[:value]
        rescue => ex
          UI.error(ex)
          UI.user_error!("Unable to set value to plist file at '#{path}'")
        end
      end

      def self.description
        "Sets value to Info.plist of your project as native Ruby data structures"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :key,
                                       env_name: "FL_SET_INFO_PLIST_PARAM_NAME",
                                       description: "Name of key in plist",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :value,
                                       env_name: "FL_SET_INFO_PLIST_PARAM_VALUE",
                                       description: "Value to setup",
                                       is_string: false,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_SET_INFO_PLIST_PATH",
                                       description: "Path to plist file you want to update",
                                       optional: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find plist file at path '#{value}'") unless File.exist?(value)
                                       end)
        ]
      end

      def self.authors
        ["kohtenko"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end

      def self.example_code
        [
          'set_info_plist_value(path: "./Info.plist", key: "CFBundleIdentifier", value: "com.krausefx.app.beta")'
        ]
      end

      def self.category
        :project
      end
    end
  end
end
