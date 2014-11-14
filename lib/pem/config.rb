module PEM
  class Config
    
    # A shared singleton
    def self.shared
      @@instance ||= Config.new
    end
    

    def signing_request
      while not @signing_request or not File.exists?@signing_request
        @signing_request = ask("Path to your .certSigningRequest file (including extension): ")
      end
      @signing_request
    end

  end
end