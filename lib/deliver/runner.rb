module Deliver
  class Runner
    attr_accessor :options

    def initialize(options)
      login(options)
      self.options = Deliver::DetectValues.new.run(options)
    end

    def login(options)
      Helper.log.info "Login to iTunes Connect (#{options[:username]})"
      Spaceship::Tunes.login(options[:username])
      Helper.log.info "Login successful"
    end

    def upload_binary
      Helper.log.info "Uploading binary to iTunes Connect"
      package_path = FastlaneCore::IpaUploadPackageBuilder.new.generate(
        app_id: options[:app].apple_id,
        ipa_path: options[:ipa],
        package_path: "/tmp"
      )

      transporter = FastlaneCore::ItunesTransporter.new(options[:username])
      result = transporter.upload(options[:app].apple_id, package_path)
    end

    def upload_metadata
      UploadMetadata.new.run(options)
    end
  end
end