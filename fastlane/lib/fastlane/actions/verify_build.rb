require 'plist'

module Fastlane
  module Actions
    class VerifyBuildAction < Action
      def self.run(params)
        Dir.mktmpdir do |dir|
          app_path = self.app_path(params, dir)

          values = self.gather_cert_info(app_path)

          values = self.update_with_profile_info(app_path, values)

          self.print_values(values)

          self.evaulate(params, values)
        end
      end

      def self.app_path(params, dir)
        build_path = params[:ipa_path] || params[:build_path] || Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] || ''
        UI.user_error!("Unable to find file '#{build_path}'") unless File.exist?(build_path)
        build_path = File.expand_path(build_path)

        case File.extname(build_path)
        when ".ipa", ".zip"
          `unzip #{build_path.shellescape} -d #{dir.shellescape} -x '__MACOSX/*' '*.DS_Store'`
          UI.user_error!("Unable to unzip ipa") unless $? == 0
          # Adding extra ** for edge-case ipas where Payload directory is nested.
          app_path = Dir["#{dir}/**/Payload/*.app"].first
        when ".xcarchive"
          app_path = Dir["#{build_path}/Products/Applications/*.app"].first
        else
          app_path = build_path # Assume that input is an app file.
        end

        UI.user_error!("Unable to find app file") unless app_path && File.exist?(app_path)
        app_path
      end

      def self.gather_cert_info(app_path)
        cert_info = `codesign -vv -d #{app_path.shellescape} 2>&1`
        UI.user_error!("Unable to verify code signing") unless $? == 0

        values = {}

        parts = cert_info.strip.split(/\r?\n/)
        parts.each do |part|
          if part =~ /\AAuthority=i(Phone|OS)/
            type = part.split('=')[1].split(':')[0]
            values['provisioning_type'] = type.downcase =~ /distribution/i ? "distribution" : "development"
          end
          if part.start_with?("Authority")
            values['authority'] ||= []
            values['authority'] << part.split('=')[1]
          end
          if part.start_with?("TeamIdentifier")
            values['team_identifier'] = part.split('=')[1]
          end
          if part.start_with?("Identifier")
            values['bundle_identifier'] = part.split('=')[1]
          end
        end

        values
      end

      def self.update_with_profile_info(app_path, values)
        profile = `cat #{app_path.shellescape}/embedded.mobileprovision | security cms -D`
        UI.user_error!("Unable to extract profile") unless $? == 0

        plist = Plist.parse_xml(profile)

        values['app_name'] = plist['AppIDName']
        values['provisioning_uuid'] = plist['UUID']
        values['team_name'] = plist['TeamName']
        values['team_identifier'] = plist['TeamIdentifier'].first

        application_identifier_prefix = plist['ApplicationIdentifierPrefix'][0]
        full_bundle_identifier = "#{application_identifier_prefix}.#{values['bundle_identifier']}"

        UI.user_error!("Inconsistent identifier found; #{plist['Entitlements']['application-identifier']}, found in the embedded.mobileprovision file, should match #{full_bundle_identifier}, which is embedded in the codesign identity") unless plist['Entitlements']['application-identifier'] == full_bundle_identifier
        UI.user_error!("Inconsistent identifier found") unless plist['Entitlements']['com.apple.developer.team-identifier'] == values['team_identifier']

        values
      end

      def self.print_values(values)
        FastlaneCore::PrintTable.print_values(config: values,
                                             title: "Summary for verify_build #{Fastlane::VERSION}")
      end

      def self.evaulate(params, values)
        if params[:provisioning_type]
          UI.user_error!("Mismatched provisioning_type. Required: '#{params[:provisioning_type]}'; Found: '#{values['provisioning_type']}'") unless params[:provisioning_type] == values['provisioning_type']
        end
        if params[:provisioning_uuid]
          UI.user_error!("Mismatched provisioning_uuid. Required: '#{params[:provisioning_uuid]}'; Found: '#{values['provisioning_uuid']}'") unless params[:provisioning_uuid] == values['provisioning_uuid']
        end
        if params[:team_identifier]
          UI.user_error!("Mismatched team_identifier. Required: '#{params[:team_identifier]}'; Found: '#{values['team_identifier']}'") unless params[:team_identifier] == values['team_identifier']
        end
        if params[:team_name]
          UI.user_error!("Mismatched team_name. Required: '#{params[:team_name]}'; Found: 'values['team_name']'") unless params[:team_name] == values['team_name']
        end
        if params[:app_name]
          UI.user_error!("Mismatched app_name. Required: '#{params[:app_name]}'; Found: '#{values['app_name']}'") unless params[:app_name] == values['app_name']
        end
        if params[:bundle_identifier]
          UI.user_error!("Mismatched bundle_identifier. Required: '#{params[:bundle_identifier]}'; Found: '#{values['bundle_identifier']}'") unless params[:bundle_identifier] == values['bundle_identifier']
        end

        UI.success("Build is verified, have a 🍪.")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Able to verify various settings in ipa file"
      end

      def self.details
        "Verifies that the built app was built using the expected build resources. This is relevant for people who build on machines that are used to build apps with different profiles, certificates and/or bundle identifiers to guard against configuration mistakes."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :provisioning_type,
                                       env_name: "FL_VERIFY_BUILD_PROVISIONING_TYPE",
                                       description: "Required type of provisioning",
                                       optional: true,
                                       verify_block: proc do |value|
                                         av = %w(distribution development)
                                         UI.user_error!("Unsupported provisioning_type, must be: #{av}") unless av.include?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :provisioning_uuid,
                                       env_name: "FL_VERIFY_BUILD_PROVISIONING_UUID",
                                       description: "Required UUID of provisioning profile",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :team_identifier,
                                       env_name: "FL_VERIFY_BUILD_TEAM_IDENTIFIER",
                                       description: "Required team identifier",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :team_name,
                                       env_name: "FL_VERIFY_BUILD_TEAM_NAME",
                                       description: "Required team name",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :app_name,
                                       env_name: "FL_VERIFY_BUILD_APP_NAME",
                                       description: "Required app name",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :bundle_identifier,
                                       env_name: "FL_VERIFY_BUILD_BUNDLE_IDENTIFIER",
                                       description: "Required bundle identifier",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :ipa_path,
                                       env_name: "FL_VERIFY_BUILD_IPA_PATH",
                                       description: "Explicitly set the ipa path",
                                       conflicting_options: [:build_path],
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :build_path,
                                       env_name: "FL_VERIFY_BUILD_BUILD_PATH",
                                       description: "Explicitly set the ipa, app or xcarchive path",
                                       conflicting_options: [:ipa_path],
                                       optional: true)
        ]
      end

      def self.output
      end

      def self.return_value
      end

      def self.authors
        ["CodeReaper"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.example_code
        [
          'verify_build(
            provisioning_type: "distribution",
            bundle_identifier: "com.example.myapp"
          )'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
