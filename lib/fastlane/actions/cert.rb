module Fastlane
  module Actions
    module SharedValues
      CERT_FILE_PATH = :CERT_FILE_PATH
      CERT_CERTIFICATE_ID = :CERT_CERTIFICATE_ID
    end

    class CertAction
      def self.run(params)
        require 'cert'

        return if Helper.test?

        Dir.chdir(FastlaneFolder.path || Dir.pwd) do
          # This should be executed in the fastlane folder

          Cert::CertRunner.run
          cert_file_path = ENV["CER_FILE_PATH"]
          certificate_id = ENV["CER_CERTIFICATE_ID"]
          Actions.lane_context[SharedValues::CERT_FILE_PATH] = cert_file_path
          Actions.lane_context[SharedValues::CERT_CERTIFICATE_ID] = certificate_id

          installed = Cert::CertChecker.is_installed?cert_file_path
          raise "Could not find the newly generated certificate installed" unless installed

          Helper.log.info("Use signing certificate '#{certificate_id}' from now on!".green)

          ENV["SIGH_CERTIFICATE_ID"] = certificate_id
        end
      end
    end
  end
end
