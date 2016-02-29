require 'plist'
require 'terminal-table'

module Fastlane
  module Actions
    module SharedValues
      VERIFY_BUILD_CUSTOM_VALUE = :VERIFY_BUILD_CUSTOM_VALUE
    end
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
        ipa_path = params[:ipa_path] || Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] || ''
        raise "Unable to find ipa file '#{ipa_path}'." unless File.exist?(ipa_path)
        ipa_path = File.expand_path(ipa_path)

        `unzip '#{ipa_path}' -d #{dir}`
        raise "Unable to unzip ipa".red unless $? == 0

        app_path = File.expand_path("#{dir}/Payload/*.app")

        app_path
      end

      def self.gather_cert_info(app_path)
        cert_info = `codesign -vv -d #{app_path} 2>&1`
        raise "Unable to verify code signing".red unless $? == 0

        values = {}

        parts = cert_info.strip.split(/\r?\n/)
        parts.each do |part|
          if part =~ /\AAuthority=i(Phone|OS)/
            type = part.split('=')[1].split(':')[0]
            values['provisioning_type'] = type.downcase =~ /distribution/i ? "distribution" : "development"
          end
          if part.start_with? "TeamIdentifier"
            values['team_identifier'] = part.split('=')[1]
          end
          if part.start_with? "Identifier"
            values['bundle_identifier'] = part.split('=')[1]
          end
        end

        values
      end

      def self.update_with_profile_info(app_path, values)
        profile = `cat #{app_path}/embedded.mobileprovision | security cms -D`
        raise "Unable to extract profile".red unless $? == 0

        plist = Plist.parse_xml(profile)

        values['app_name'] = plist['AppIDName']
        values['provisioning_uuid'] = plist['UUID']
        values['team_name'] = plist['TeamName']

        application_identifier_prefix = plist['ApplicationIdentifierPrefix'][0]
        full_bundle_identifier = "#{application_identifier_prefix}.#{values['bundle_identifier']}"

        raise "Inconsistent identifier found; #{plist['Entitlements']['application-identifier']}, found in the embedded.mobileprovision file, should match #{full_bundle_identifier}, which is embedded in the codesign identity" unless plist['Entitlements']['application-identifier'] == full_bundle_identifier
        raise "Inconsistent identifier found" unless plist['Entitlements']['com.apple.developer.team-identifier'] == values['team_identifier']

        values
      end

      def self.print_values(values)
        table = Terminal::Table.new do |t|
          t.title = 'Summary for VERIFY_BUILD'.green
          t.headings = 'Key', 'Value'
          values.each do |key, value|
            columns = []
            columns << key
            columns << case value
                       when Hash
                         value.map {|k, v| "#{k}: #{v}"}.join("\n")
                       when Array
                         value.join("\n")
                       else
                         value.to_s
                       end

            t << columns
          end
        end

        puts ""
        puts table
        puts ""
      end

      def self.evaulate(params, values)
        if params[:provisioning_type]
          raise "Mismatched provisioning_type. Required: '#{params[:provisioning_type]}''; Found: '#{values['provisioning_type']}'".red unless params[:provisioning_type] == values['provisioning_type']
        end
        if params[:provisioning_uuid]
          raise "Mismatched provisioning_uuid. Required: '#{params[:provisioning_uuid]}'; Found: '#{values['provisioning_uuid']}'".red unless params[:provisioning_uuid] == values['provisioning_uuid']
        end
        if params[:team_identifier]
          raise "Mismatched team_identifier. Required: '#{params[:team_identifier]}'; Found: '#{values['team_identifier']}'".red unless params[:team_identifier] == values['team_identifier']
        end
        if params[:team_name]
          raise "Mismatched team_name. Required: '#{params[:team_name]}'; Found: 'values['team_name']'".red unless params[:team_name] == values['team_name']
        end
        if params[:app_name]
          raise "Mismatched app_name. Required: '#{params[:app_name]}'; Found: '#{values['app_name']}'".red unless params[:app_name] == values['app_name']
        end
        if params[:bundle_identifier]
          raise "Mismatched bundle_identifier. Required: '#{params[:bundle_identifier]}'; Found: '#{values['bundle_identifier']}'".red unless params[:bundle_identifier] == values['bundle_identifier']
        end

        UI.success "Build is verified, have a 🍪."
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Able to verify various settings in ipa file"
      end

      def self.details
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :provisioning_type,
                                       env_name: "FL_VERIFY_BUILD_PROVISIONING_TYPE",
                                       description: "Required type of provisioning",
                                       optional: true,
                                       verify_block: proc do |value|
                                         av = %w(distribution development)
                                         raise "Unsupported provisioning_type, must be: #{av}" unless av.include?(value)
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
    end
  end
end
