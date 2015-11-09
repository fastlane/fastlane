require 'shellwords'

module Fastlane
  module Actions
    class SetupCodesigningAction < Action
      def self.run(params)
        params[:path] = Helper::CodesigningHelper.clone(params[:git_url]) if params[:git_url]

        certs = Dir[File.join(params[:path], "**", "*.cer")]
        keys = Dir[File.join(params[:path], "**", "*.p12")]
        profiles = Dir[File.join(params[:path], "**", "*.mobileprovision")]

        certs.each do |cert|
          if FastlaneCore::CertChecker.installed?(cert)
            Helper.log.info "Certificate '#{cert}' is already installed on this machine"
          else
            Helper::CodesigningHelper.import(params, cert)
          end
        end

        # Import all the private keys
        keys.each do |key|
          Helper::CodesigningHelper.import(params, key)
        end

        if certs.count == 0 or keys.count == 0
          Helper.log.error "Couldn't find a valid code signing identity in the git repo".red

          arguments = ConfigurationHelper.parse(Actions::CertAction, {
            development: params[:type] == :development,
            output_path: File.join(params[:path], "certs")
          })

          Actions::CertAction.run(arguments)
          # We don't care about the signing request
          Dir[File.join(params[:path], "**", "*.certSigningRequest")].each { |path| File.delete(path) }
        end

        # Install the provisioning profiles
        identifiers = profiles.collect do |profile|
          FastlaneCore::ProvisioningProfile.install(profile)
          FastlaneCore::ProvisioningProfile.parse(profile).fetch('Entitlements', {}).fetch('application-identifier', nil)
        end

        # Do we need to create a provisioning profile
        if params[:app_identifier]
          # identifiers include the prefix, e.g. 439BBMAA67.tools.fastlane.app
          unless identifiers.any? { |a| a.include?(params[:app_identifier]) }
            arguments = ConfigurationHelper.parse(Actions::SighAction, {
              app_identifier: params[:app_identifier],
              adhoc: params[:type] == :adhoc,
              development: params[:type] == :development,
              output_path: File.join(params[:path], "profiles")
            })

            Actions::SighAction.run(arguments)
          end
        end

        Helper::CodesigningHelper.commit_changes(params[:path]) if params[:git_url]

        # We have to remove the provisioning profile path from the lane context
        # as the temporary folder gets deleted
        Actions.lane_context[SharedValues::SIGH_PROFILE_PATHS] = nil

        Helper.log.info "All required keys, certificates and provisioning profiles are installed 🙌".green
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Automatically installs the required certificate and provisioning profiles"
      end

      def self.details
        "TODO"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_SETUP_CODESIGNING_PATH",
                                       description: "Path to the certificates directory",
                                       default_value: File.join('fastlane', 'certificates'),
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Directory not found at path '#{value}'".red unless File.directory?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :git_url,
                                       env_name: "FL_SETUP_CODESIGNING_GIT_URl",
                                       description: "URL to the git repo containing all the certificates",
                                       optional: true,
                                       verify_block: proc do |value|
                                         # TODO
                                       end),
          FastlaneCore::ConfigItem.new(key: :type,
                                       env_name: "FL_SETUP_CODESIGNING_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one",
                                       verify_block: proc do |value|
                                         value = value.to_sym
                                         supported = [:appstore, :adhoc, :development, :enterprise]
                                         unless supported.include?(value)
                                           raise "Unsupported environment #{value}, must be in #{supported.join(', ')}".red
                                         end
                                       end,
                                       default_value: :appstore),
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                     short_option: "-a",
                                     env_name: "FL_SETUP_CODESIGNING_APP_IDENTIFIER",
                                     description: "The bundle identifier of your app",
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)),
          FastlaneCore::ConfigItem.new(key: :username,
                                       short_option: "-u",
                                       env_name: "FL_SETUP_CODESIGNING_USERNAME",
                                       description: "Your Apple ID Username",
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)),
          FastlaneCore::ConfigItem.new(key: :keychain_name,
                                       env_name: "KEYCHAIN_NAME",
                                       description: "Keychain the items should be imported to",
                                       default_value: "login.keychain")
        ]
      end

      def self.output
        []
      end

      def self.return_value
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
