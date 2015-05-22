require 'pbxplorer'
module Fastlane
  module Actions
    module SharedValues
      
    end

    class UpdateProjectProvisioningAction < Action
      ROOT_CERTIFICATE_URL = "http://www.apple.com/appleca/AppleIncRootCertificate.cer"
      def self.run(params)
        
        # assign folder from parameter or search for xcodeproj file
        folder = params[:xcodeproj] || Dir["*.xcodeproj"].first
        
        # validate folder
        folder = File.join(folder, "project.pbxproj")
        raise "Could not find path to project config '#{folder}'. Pass the path to your project (not workspace)!".red unless File.exists?(folder)

        # download certificate
        if not File.exists?(params[:certificate])
          Helper.log.info("Downloading root certificate from (#{ROOT_CERTIFICATE_URL}) to path '#{params[:certificate]}'")
          require 'open-uri'
          File.open(params[:certificate], "w") do |file|
            file.write(open(ROOT_CERTIFICATE_URL, "rb").read)
          end
        end

        # parsing mobileprovision file
        Helper.log.info("Parsing mobile provisioning profile from '#{params[:profile]}'")
        profile = File.read(params[:profile])
        p7 = OpenSSL::PKCS7.new(profile)
        store = OpenSSL::X509::Store.new
        cert = OpenSSL::X509::Certificate.new(File.read(params[:certificate]))
        store.add_cert(cert)
        verification = p7.verify([cert], store)
        data = Plist::parse_xml(p7.data)
        
        # manipulate project file
        Helper.log.info("Updating project '#{folder}' with UUID")
        project_file = XCProjectFile.new(folder)
        project_file.project.targets.first.build_configuration_list.build_configurations.each do |build_configuration|
          build_configuration["buildSettings"]["PROVISIONING_PROFILE"] = data["UUID"]
          build_configuration["buildSettings"]["CODE_SIGN_RESOURCE_RULES_PATH[sdk=*]"] = "$(SDKROOT)/ResourceRules.plist"
        end
        project_file.save

        # complete
        Helper.log.info("Successfully updated project settings in'#{params[:xcodeproj]}'".green)
      end

      def self.description
        "Update projects code signing settings from your profisioning profile"
      end

      def self.details
        "This action retrieves a provisioning profile UUID from a provisioning profile (.mobileprovision) to set up the xcode projects' code signing settings in *.xcodeproj/project.pbxproj"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                       env_name: "FL_PROJECT_PROVISIONING_PROJECT_PATH",
                                       description: "Path to your Xcode project",
                                       optional: true,
                                       verify_block: Proc.new do |value|
                                        raise "Path to xcode project is invalid".red unless File.exists?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :profile,
                                       env_name: "FL_PROJECT_PROVISIONING_PROFILE_FILE_NAME",
                                       description: "Path to provisioning profile (.mobileprovision)",
                                       default_value: ENV["SIGH_PROFILE_FILE_NAME"],
                                       verify_block: Proc.new do |value|
                                        raise "Path to provisioning profile is invalid".red unless File.exists?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :certificate,
                                       env_name: "FL_PROJECT_PROVISIONING_CERTIFICATE_PATH",
                                       description: "Path to apple root certificate",
                                       default_value: "AppleIncRootCertificate.cer")
        ]
      end

      def self.author
        "tobiasstrebitzer"
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
