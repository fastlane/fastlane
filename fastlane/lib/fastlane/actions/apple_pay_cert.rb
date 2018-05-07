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

        puts(csr)
        # puts(pkey)

        begin 
        	puts params[:app_identifier]
        	# require 'pry'
        	# binding.pry
        	cert = certificate.create!(csr: csr, bundle_id: params[:app_identifier])
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
        'Update a Info.plist file with bundle identifier and display name'
      end

      def self.details
        "This action allows you to modify your `Info.plist` file before building. This may be useful if you want a separate build for alpha, beta or nightly builds, but don't want a separate target."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "username",
                                       description: ""),
              FastlaneCore::ConfigItem.new(key: :app_identifier,
                                       env_name: "app_identifier",
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
