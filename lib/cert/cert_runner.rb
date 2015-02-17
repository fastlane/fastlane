module Cert
  class CertRunner
    def self.run
      FastlaneCore::DeveloperCenter.new.run
    end
  end
end