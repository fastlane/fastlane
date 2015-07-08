module Cert
  class CertRunner
    def self.run
      Cert::DeveloperCenter.new.run

      installed = FastlaneCore::CertChecker.is_installed?ENV["CER_FILE_PATH"]
      raise "Could not find the newly generated certificate installed" unless installed
    end
  end
end