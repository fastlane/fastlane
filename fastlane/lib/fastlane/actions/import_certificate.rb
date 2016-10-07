require 'shellwords'

module Fastlane
  module Actions
    class ImportCertificateAction < Action
      def self.run(params)
        command = "security import #{params[:certificate_path].shellescape} -k ~/Library/Keychains/#{params[:keychain_name].shellescape}"
        command << " -P #{params[:certificate_password].shellescape}" if params[:certificate_password]
        command << " -T /usr/bin/codesign"
        command << " -T /usr/bin/security"

        Fastlane::Actions.sh(command, log: params[:log_output])
      end

      def self.description
        "Import certificate from inputfile into a keychain"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :keychain_name,
                                       env_name: "KEYCHAIN_NAME",
                                       description: "Keychain the items should be imported to",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :certificate_path,
                                       description: "Path to certificate",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :certificate_password,
                                       description: "Certificate password",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :log_output,
                                       description: "If output should be logged to the console",
                                       type: TrueClass,
                                       default_value: false,
                                       optional: true)
        ]
      end

      def self.authors
        ["gin0606"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.details
        "Import certificates into the current default keychain. Use `create_keychain` to create a new keychain."
      end

      def self.example_code
        [
          'import_certificate(certificate_path: "certs/AppleWWDRCA.cer")',
          'import_certificate(
            certificate_path: "certs/dist.p12",
            certificate_password: ENV["CERTIFICATE_PASSWORD"] || "default"
          )'
        ]
      end

      def self.category
        :code_signing
      end
    end
  end
end
