require 'shellwords'

module Fastlane
  module Actions
    class ImportCertificateAction < Action
      def self.run(params)
        command = "security import #{params[:certificate_path].shellescape} -k ~/Library/Keychains/#{params[:keychain_name].shellescape}"
        command << " -P #{params[:certificate_password].shellescape}" if params[:certificate_password]
        command << " -T /usr/bin/codesign"
        command << " -T /usr/bin/security"

        Fastlane::Actions.sh command, log: false
      end

      def self.description
        "Import certificate from inputfile into a keychain"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :keychain_name,
                                       env_name: "KEYCHAIN_NAME",
                                       description: "Keychain name into which item",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :certificate_path,
                                       env_name: "",
                                       description: "Path to certificate",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :certificate_password,
                                       env_name: "",
                                       description: "Certificate password",
                                       optional: true)
        ]
      end

      def self.authors
        ["gin0606"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
