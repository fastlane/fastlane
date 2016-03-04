module Fastlane
  module Actions
    # Resigns the ipa
    class ResignAction < Action
      def self.run(params)
        require 'sigh'

        # try to resign the ipa
        if Sigh::Resign.resign(params[:ipa], params[:signing_identity], params[:provisioning_profile], params[:entitlements], params[:version])
          Helper.log.info 'Successfully re-signed .ipa 🔏.'.green
        else
          raise 'Failed to re-sign .ipa'.red
        end
      end

      def self.description
        "Codesign an existing ipa file"
      end

      def self.details
        [
          "You may provide multiple provisioning profiles if the application contains",
          "nested applications or app extensions, which need their own provisioning",
          "profile. You can do so by passing an array of provisiong profile strings or a",
          "hash that associates provisioning profile values to bundle identifier keys.",
          "",
          "resign(ipa: \"path\", signing_identity: \"identity\", provisioning_profile: {",
          "  \"com.example.awesome-app\" => \"App.mobileprovision\",",
          "  \"com.example.awesome-app.app-extension\" => \"Extension.mobileprovision\"",
          "})"
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :ipa,
                                       env_name: "FL_RESIGN_IPA",
                                       description: "Path to the ipa file to resign. Optional if you use the `gym` or `xcodebuild` action",
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                       verify_block: proc do |value|
                                         raise "Couldn't find ipa file at path '#{value}'".red unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :signing_identity,
                                       env_name: "FL_RESIGN_SIGNING_IDENTITY",
                                       description: "Code signing identity to use. e.g. \"iPhone Distribution: Luka Mirosevic (0123456789)\""),
          FastlaneCore::ConfigItem.new(key: :entitlements,
                                       env_name: "FL_RESIGN_ENTITLEMENTS",
                                       description: "Path to the entitlement file to use, e.g. \"myApp/MyApp.entitlements\"",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :provisioning_profile,
                                       env_name: "FL_RESIGN_PROVISIONING_PROFILE",
                                       description: "Path to your provisioning_profile. Optional if you use `sigh`",
                                       default_value: Actions.lane_context[SharedValues::SIGH_PROFILE_PATH],
                                       is_string: false,
                                       verify_block: proc do |value|
                                         files = case value
                                                 when Hash then value.values
                                                 when Enumerable then value
                                                 else [value]
                                                 end
                                         files.each do |file|
                                           raise "Couldn't find provisiong profile at path '#{file}'".red unless File.exist?(file)
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "FL_RESIGN_VERSION",
                                       description: "Version number to force resigned ipa to use",
                                       is_string: true,
                                       optional: true)
        ]
      end

      def self.author
        "lmirosevic"
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
