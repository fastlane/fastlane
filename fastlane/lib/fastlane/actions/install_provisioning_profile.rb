require 'shellwords'

module Fastlane
  module Actions
    class InstallProvisioningProfileAction < Action
      def self.run(params)
        profile_path = params[:provisioning_profile_path]
        absolute_profile_path = File.expand_path(profile_path)
        if File.exist?(absolute_profile_path)
          FastlaneCore::ProvisioningProfile.install(absolute_profile_path)
        else
          UI.user_error!("Failed installation of provisioning profile from file at path: '#{profile_path}'")
        end
      end

      def self.description
        "Install provisioning profile from inputfile"
      end

      def self.details
        "Install provisioning profile from inputfile for current user"
      end

      def self.authors
        ["SofteqDG"]
      end

      def self.category
        :code_signing
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :provisioning_profile_path,
                                  env_name: "FL_INSTALL_PROVISIONING_PROFILE_PATH",
                               description: "Path to provisioning profile",
                                  optional: false,
                                      type: String)
        ]
      end

      def self.return_value
        "The absolute path to the installed provisioning profile"
      end

      def self.example_code
        [
          'install_provisioning_profile(provisioning_profile_path: "profiles/profile.mobileprovision")'
        ]
      end
    end
  end
end
