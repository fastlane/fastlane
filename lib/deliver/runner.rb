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
      # First, collect all the things for the HTML Report
      screenshots = UploadScreenshots.new.collect_screenshots(options)
      UploadMetadata.new.load_from_filesystem(options)

      # Validate
      validate_html(screenshots)

      # Commit
      UploadMetadata.new.upload(options)
      UploadScreenshots.new.upload(options, screenshots)
    end

    private

    def validate_html(screenshots)
      html_path = HtmlGenerator.new.render(options, screenshots, '.')
      # unless options[:force]
        puts "----------------------------------------------------------------------------"
        puts "Verifying the upload via the HTML file can be disabled by either adding"
        puts "'skip_pdf true' to your Deliverfile or using the flag --force."
        puts "----------------------------------------------------------------------------"

        system("open '#{html_path}'")
        okay = agree("Does the Preview on path '#{html_path}' look okay for you? (blue = updated) (y/n)", true)

        unless okay
          raise "Did not upload the metadata, because the HTML file was rejected by the user".yellow
        end
      # end
    end
  end
end
