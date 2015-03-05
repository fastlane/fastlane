module Cert
  class CertRunner
    def self.run(type)
      Cert::DeveloperCenter.new.run(type)
    end
  end
end