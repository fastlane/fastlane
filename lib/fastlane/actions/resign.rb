module Fastlane
  module Actions
    # Resigns the ipa
    class ResignAction < Action
      def self.run(params)
        require 'sigh'

        params = params.first

        raise 'You must pass valid params to the resign action. Please check the README.md'.red if (params.nil? || params.empty?)

        ipa                   = params[:ipa] || Actions.lane_context[SharedValues::IPA_OUTPUT_PATH]
        signing_identity      = params[:signing_identity]
        provisioning_profile  = params[:provisioning_profile] || Actions.lane_context[SharedValues::SIGH_PROFILE_PATH]

        raise 'Please pass a valid ipa which should be a path to an ipa on disk'.red unless ipa
        raise 'Please pass a valid signing_identity'.red unless signing_identity
        raise 'Please pass a valid provisioning_profile which should be a path to a profile on disk.'.red unless provisioning_profile

        # try to resign the ipa
        if Sigh::Resign.resign(ipa, signing_identity, provisioning_profile)
          Helper.log.info 'Successfully re-signed .ipa 🔏.'.green
        else
          raise 'Failed to re-sign .ipa'.red
        end
      end

      def self.description
        "Code sign an existing ipa file"
      end

      def self.available_options
        [
          ['ipa', 'Path to the ipa file to resign. Optional if you use the `ipa` or `xcodebuild` action'],
          ['signing_identity', 'Code signing identity to use. e.g. "iPhone Distribution: Luka Mirosevic (0123456789)"'],
          ['provisioning_profile', 'Path to your provisioning_profile. Optional if you use `sigh`']
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
