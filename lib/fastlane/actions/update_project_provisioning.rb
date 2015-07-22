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
        raise "Could not find valid certificate at '#{params[:certificate]}'" unless (File.size(params[:certificate]) > 0)
        cert = OpenSSL::X509::Certificate.new(File.read(params[:certificate]))
        store.add_cert(cert)
        verification = p7.verify([cert], store)
        data = Plist::parse_xml(p7.data)
        
        filter = params[:build_configuration_filter]

        # manipulate project file
        Helper.log.info("Going to update project '#{folder}' with UUID".green)
        require 'pbxplorer'

        project_file = XCProjectFile.new(folder)
        project_file.project.targets.each do |target|
          if filter
            if target['productName'].match(filter) or target['productType'].match(filter)
              Helper.log.info "Updating target #{target['productName']}...".green
            else
              Helper.log.info "Skipping target #{target['productName']} as it doesn't match the filter '#{filter}'".yellow
              next
            end
          else
            Helper.log.info "Updating target #{target['productName']}...".green
          end

          target.build_configuration_list.build_configurations.each do |build_configuration|
            build_configuration["buildSettings"]["PROVISIONING_PROFILE"] = data["UUID"]
            build_configuration["buildSettings"]["CODE_SIGN_RESOURCE_RULES_PATH[sdk=*]"] = "$(SDKROOT)/ResourceRules.plist"
          end
        end

        project_file.save

        # complete
        Helper.log.info("Successfully updated project settings in'#{params[:xcodeproj]}'".green)
      end

      def self.description
        "Update projects code signing settings from your profisioning profile"
      end

      def self.details
        [
          "This action retrieves a provisioning profile UUID from a provisioning profile (.mobileprovision) to set",
          "up the xcode projects' code signing settings in *.xcodeproj/project.pbxproj",
          "",
          "The `build_configuration_filter` value can be used to only update code signing for one target",
          "Example Usage is the WatchKit Extension or WatchKit App, where you need separate provisioning profiles",
          "Example: `update_project_provisioning(xcodeproj: \"..\", build_configuration_filter: \".*WatchKit App.*\")"
        ].join("\n")
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
                                       env_name: "FL_PROJECT_PROVISIONING_PROFILE_FILE",
                                       description: "Path to provisioning profile (.mobileprovision)",
                                       default_value: Actions.lane_context[SharedValues::SIGH_PROFILE_PATH],
                                       verify_block: Proc.new do |value|
                                        raise "Path to provisioning profile is invalid".red unless File.exists?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :build_configuration_filter,
                                       env_name: "FL_PROJECT_PROVISIONING_PROFILE_FILTER",
                                       description: "A filter for the target name. Use a standard regex",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :certificate,
                                       env_name: "FL_PROJECT_PROVISIONING_CERTIFICATE_PATH",
                                       description: "Path to apple root certificate",
                                       default_value: "/tmp/AppleIncRootCertificate.cer")
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
