module Cert
  class CertRunner
    def self.run
      DeveloperCenter.new.create_cert
    end
  end
end