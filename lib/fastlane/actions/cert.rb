module Fastlane
  module Actions
    module SharedValues
      CERT_FILE_PATH = :CERT_FILE_PATH
      CERT_CERTIFICATE_ID = :CERT_CERTIFICATE_ID
    end

    class CertAction
      
      def self.is_supported?(type)
        type == :ios
      end

      def self.run(params)
        require 'cert'
        require 'cert/options'

        return if Helper.test?

        Dir.chdir(FastlaneFolder.path || Dir.pwd) do
          # This should be executed in the fastlane folder

          values = params.first
          unless values.kind_of?Hash
            # Old syntax
            values = {}
            params.each do |val|
              values[val] = true
            end
          end

          Cert.config = FastlaneCore::Configuration.create(Cert::Options.available_options, (values || {}))

          Cert::CertRunner.run
          cert_file_path = ENV["CER_FILE_PATH"]
          certificate_id = ENV["CER_CERTIFICATE_ID"]
          Actions.lane_context[SharedValues::CERT_FILE_PATH] = cert_file_path
          Actions.lane_context[SharedValues::CERT_CERTIFICATE_ID] = certificate_id

          Helper.log.info("Use signing certificate '#{certificate_id}' from now on!".green)

          ENV["SIGH_CERTIFICATE_ID"] = certificate_id
        end
      end
    end
  end
end
