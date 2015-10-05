module Fastlane
  module Actions
    # Resigns the ipa
    class ResignAction < Action
      def self.run(params)
        require 'sigh'

        # try to resign the ipa
        if Sigh::Resign.resign(params[:ipa], params[:signing_identity], params[:provisioning_profile])
          Helper.log.info 'Successfully re-signed .ipa 🔏.'.green
        else
          raise 'Failed to re-sign .ipa'.red
        end
      end

      def self.description
        "Codesign an existing ipa file"
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
          FastlaneCore::ConfigItem.new(key: :provisioning_profile,
                                       env_name: "FL_RESIGN_PROVISIONING_PROFILE",
                                       description: "Path to your provisioning_profile. Optional if you use `sigh`",
                                       default_value: Actions.lane_context[SharedValues::SIGH_PROFILE_PATH],
                                       verify_block: proc do |value|
                                         raise "No provisioning_profile file given or found, pass using `provisioning_profile: 'path/app.mobileprovision'`".red unless File.exist?(value)
                                       end)
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
