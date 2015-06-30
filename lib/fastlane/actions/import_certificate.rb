module Fastlane
  module Actions
    class ImportCertificateAction < Action
      def self.run(params)
        command = "security import #{params[:certificate_path]} -k ~/Library/Keychains/#{params[:keychain_name]}"
        command << " -P #{params[:certificate_password]}" if params[:certificate_password]
        command << " -T /usr/bin/codesign"

        sh command
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
                                       optional: true),
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
