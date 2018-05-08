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
                                       description: "")
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
