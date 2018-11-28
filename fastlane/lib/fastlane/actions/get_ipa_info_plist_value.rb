module Fastlane
  module Actions
    module SharedValues
      GET_IPA_INFO_PLIST_VALUE_CUSTOM_VALUE = :GET_IPA_INFO_PLIST_VALUE_CUSTOM_VALUE
    end

    class GetIpaInfoPlistValueAction < Action
      def self.run(params)
        ipa = File.expand_path(params[:ipa])
        key = params[:key]
        plist = FastlaneCore::IpaFileAnalyser.fetch_info_plist_file(ipa)
        value = plist[key]

        Actions.lane_context[SharedValues::GET_IPA_INFO_PLIST_VALUE_CUSTOM_VALUE] = value

        return value
      rescue => ex
        UI.error(ex)
        UI.error("Unable to find plist file at '#{ipa}'")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Returns a value from Info.plist inside a .ipa file"
      end

      def self.details
        "This is useful for introspecting Info.plist files for `.ipa` files that have already been built."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :key,
                                       env_name: "FL_GET_IPA_INFO_PLIST_VALUE_KEY",
                                       description: "Name of parameter",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :ipa,
                                       env_name: "FL_GET_IPA_INFO_PLIST_VALUE_IPA",
                                       description: "Path to IPA",
                                       is_string: true,
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                       default_value_dynamic: true)
        ]
      end

      def self.output
        [
          ['GET_IPA_INFO_PLIST_VALUE_CUSTOM_VALUE', 'The value of the last plist file that was parsed']
        ]
      end

      def self.return_value
        "Returns the value in the .ipa's Info.plist corresponding to the passed in Key"
      end

      def self.authors
        ["johnboiles"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'get_ipa_info_plist_value(ipa: "path.ipa", key: "KEY_YOU_READ")'
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
