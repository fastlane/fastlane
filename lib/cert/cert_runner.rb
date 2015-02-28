module Cert
  class CertRunner
    def self.run(type)
      FastlaneCore::DeveloperCenter.new.run(type)
    end
  end
end