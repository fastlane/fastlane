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
          new_plist = plist.to_plist
          File.write(path, new_plist)

          return params[:value]
        rescue => ex
          Helper.log.error ex
          Helper.log.error "Unable to set value to plist file at '#{path}'".red
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
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_SET_INFO_PLIST_PATH",
                                       description: "Path to plist file you want to update",
                                       optional: false,
                                       verify_block: proc do |value|
                                         raise "Couldn't find plist file at path '#{value}'".red unless File.exist?(value)
                                       end)
        ]
      end

      def self.output
        []
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
