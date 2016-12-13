module Fastlane
  module Actions
    module SharedValues
      CERT_FILE_PATH = :CERT_FILE_PATH
      CERT_CERTIFICATE_ID = :CERT_CERTIFICATE_ID
    end

    class CertAction < Action
      def self.run(params)
        require 'cert'

        return if Helper.test?

        begin
          Cert.config = params # we alread have the finished config

          Cert::Runner.new.launch
          cert_file_path = ENV["CER_FILE_PATH"]
          certificate_id = ENV["CER_CERTIFICATE_ID"]
          Actions.lane_context[SharedValues::CERT_FILE_PATH] = cert_file_path
          Actions.lane_context[SharedValues::CERT_CERTIFICATE_ID] = certificate_id

          UI.success("Use signing certificate '#{certificate_id}' from now on!")

          ENV["SIGH_CERTIFICATE_ID"] = certificate_id # for further use in the sigh action
        end
      end

      def self.description
        "Fetch or generate the latest available code signing identity"
      end

      def self.details
        [
          "**Important**: It is recommended to use [match](https://github.com/fastlane/fastlane/tree/master/match) according to the [codesigning.guide](https://codesigning.guide) for generating and maintaining your certificates. Use _cert_ directly only if you want full control over what's going on and know more about codesigning.",
          "Use this action to download the latest code signing identity"
        ].join("\n")
      end

      def self.available_options
        require 'cert'
        Cert::Options.available_options
      end

      def self.author
        "KrauseFx"
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.example_code
        [
          'cert',
          'cert(
            development: true,
            username: "user@email.com"
          )'
        ]
      end

      def self.category
        :code_signing
      end
    end
  end
end
