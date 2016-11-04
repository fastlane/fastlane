module Deliver
  class Runner
    attr_accessor :options

    def initialize(options, skip_auto_detection = {})
      self.options = options
      login
      Deliver::DetectValues.new.run!(self.options, skip_auto_detection)
      FastlaneCore::PrintTable.print_values(config: options, hide_keys: [:app], mask_keys: ['app_review_information.demo_password'], title: "deliver #{Deliver::VERSION} Summary")
    end

    def login
      UI.message("Login to iTunes Connect (#{options[:username]})")
      Spaceship::Tunes.login(options[:username])
      Spaceship::Tunes.select_team
      UI.message("Login successful")
    end

    def run
      verify_version if options[:app_version].to_s.length > 0
      upload_metadata

      has_binary = (options[:ipa] || options[:pkg])
      if !options[:skip_binary_upload] && !options[:build_number] && has_binary
        upload_binary
      end

      UI.success("Finished the upload to iTunes Connect")

      submit_for_review if options[:submit_for_review]
    end

    # Make sure the version on iTunes Connect matches the one in the ipa
    # If not, the new version will automatically be created
    def verify_version
      app_version = options[:app_version]
      UI.message("Making sure the latest version on iTunes Connect matches '#{app_version}' from the ipa file...")

      changed = options[:app].ensure_version!(app_version)
      if changed
        UI.success("Successfully set the version to '#{app_version}'")
      else
        UI.success("'#{app_version}' is the latest version on iTunes Connect")
      end
    end

    # Upload all metadata, screenshots, pricing information, etc. to iTunes Connect
    def upload_metadata
      # First, collect all the things for the HTML Report
      screenshots = UploadScreenshots.new.collect_screenshots(options)
      UploadMetadata.new.load_from_filesystem(options)
      UploadMetadata.new.assign_defaults(options)

      # Validate
      validate_html(screenshots)

      # Commit
      UploadMetadata.new.upload(options)
      UploadScreenshots.new.upload(options, screenshots)
      UploadPriceTier.new.upload(options)
      UploadAssets.new.upload(options) # e.g. app icon
    end

    # Upload the binary to iTunes Connect
    def upload_binary
      UI.message("Uploading binary to iTunes Connect")
      if options[:ipa]
        package_path = FastlaneCore::IpaUploadPackageBuilder.new.generate(
          app_id: options[:app].apple_id,
          ipa_path: options[:ipa],
          package_path: "/tmp"
        )
      elsif options[:pkg]
        package_path = FastlaneCore::PkgUploadPackageBuilder.new.generate(
          app_id: options[:app].apple_id,
          pkg_path: options[:pkg],
          package_path: "/tmp"
        )
      end

      transporter = FastlaneCore::ItunesTransporter.new(options[:username], nil, false, options[:itc_provider])
      result = transporter.upload(options[:app].apple_id, package_path)
      UI.user_error!("Could not upload binary to iTunes Connect. Check out the error above", show_github_issues: true) unless result
    end

    def submit_for_review
      SubmitForReview.new.submit!(options)
    end

    private

    def validate_html(screenshots)
      return if options[:force]
      return if options[:skip_metadata] && options[:skip_screenshots]
      HtmlGenerator.new.run(options, screenshots)
    end
  end
end
