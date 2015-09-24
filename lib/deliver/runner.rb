module Deliver
  class Runner
    attr_accessor :options

    def initialize(options)
      self.options = options
      login
      Deliver::DetectValues.new.run!(self.options)
    end

    def login
      Helper.log.info "Login to iTunes Connect (#{options[:username]})"
      Spaceship::Tunes.login(options[:username])
      Helper.log.info "Login successful"
    end

    def run
      upload_metadata unless options[:skip_metadata]
      # upload_binary if options[:ipa]
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
      # UploadMetadata.new.run(options)
      UploadScreenshots.new.run(options)
    end
  end
end
