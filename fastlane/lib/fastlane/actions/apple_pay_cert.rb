require 'spaceship'

module Fastlane
  module Actions
    module SharedValues
    end

    class ApplePayCertAction < Action
      def self.run(params)
        UI.message("Starting login with user '#{params[:username]}'")
        Spaceship.login(params[:username], nil)
        Spaceship.client.select_team
        UI.message("Successfully logged in")

        create_certificate(params)
      end

      def self.create_certificate(params)
        UI.important("Creating a new Apple Pay certificate.")
        csr, pkey = Spaceship.certificate.create_apple_pay_certificate_signing_request

        begin
          cert = certificate.create!(csr: csr, bundle_id: params[:merchant_bundle_id])
        rescue => ex
          raise ex
        end
      end

      def self.certificate
        Spaceship.certificate.apple_pay_certificate
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end

      def self.description
        'Creates Apple Pay certificate.'
      end

      def self.details
        "This action allows you to create Apple Pay merchant certificate."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "username",
                                       description: ""),
          FastlaneCore::ConfigItem.new(key: :merchant_bundle_id,
                                   env_name: "merchant_bundle_id",
                                   description: ""),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                 short_option: "-b",
                                 env_name: "APPLE_PAY_CERT_TEAM_ID",
                                 code_gen_sensitive: true,
                                 default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                 default_value_dynamic: true,
                                 description: "The ID of your Developer Portal team if you're in multiple teams",
                                 optional: true,
                                 verify_block: proc do |value|
                                   ENV["FASTLANE_TEAM_ID"] = value.to_s
                                 end),
          FastlaneCore::ConfigItem.new(key: :team_name,
                                       short_option: "-l",
                                       env_name: "APPLE_PAY_CERT_TEAM_NAME",
                                       description: "The name of your Developer Portal team if you're in multiple teams",
                                       optional: true,
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_name),
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         ENV["FASTLANE_TEAM_NAME"] = value.to_s
                                       end)
        ]
      end

      def self.author
        'rishabhtayal'
      end

      def self.example_code
        [

        ]
      end

      def self.category
        :project
      end
    end
  end
end
