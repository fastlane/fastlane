require 'precheck/options'
require 'precheck/runner'
require 'fastlane_core/configuration/configuration'
require 'fastlane_core/crash_reporter/crash_reporter'
require 'fastlane_core/ipa_upload_package_builder'
require 'fastlane_core/pkg_upload_package_builder'
require 'fastlane_core/itunes_transporter'
require 'spaceship'
require_relative 'html_generator'
require_relative 'submit_for_review'
require_relative 'upload_assets'
require_relative 'upload_price_tier'
require_relative 'upload_metadata'
require_relative 'upload_screenshots'
require_relative 'detect_values'

module Deliver
  class Runner
    attr_accessor :options

    def initialize(options, skip_auto_detection = {})
      self.options = options

      login

      Deliver::DetectValues.new.run!(self.options, skip_auto_detection)
      FastlaneCore::PrintTable.print_values(config: options, hide_keys: [:app], mask_keys: ['app_review_information.demo_password'], title: "deliver #{Fastlane::VERSION} Summary")
    end

    def login
      UI.message("Login to iTunes Connect (#{options[:username]})")
      Spaceship::Tunes.login(options[:username])
      Spaceship::Tunes.select_team
      UI.message("Login successful")
    end

    def run
      verify_version if options[:app_version].to_s.length > 0 && !options[:skip_app_version_update]
      upload_metadata

      has_binary = (options[:ipa] || options[:pkg])
      if !options[:skip_binary_upload] && !options[:build_number] && has_binary
        upload_binary
      end

      UI.success("Finished the upload to iTunes Connect") unless options[:skip_binary_upload]

      precheck_success = precheck_app

      submit_for_review if options[:submit_for_review] && precheck_success
    end

    # Make sure we pass precheck before uploading
    def precheck_app
      return true unless options[:run_precheck_before_submit]
      UI.message("Running precheck before submitting to review, if you'd like to disable this check you can set run_precheck_before_submit to false")

      if options[:submit_for_review]
        UI.message("Making sure we pass precheck 👮‍♀️ 👮 before we submit  🛫")
      else
        UI.message("Running precheck 👮‍♀️ 👮")
      end

      precheck_options = {
        default_rule_level: options[:precheck_default_rule_level],
        include_in_app_purchases: options[:precheck_include_in_app_purchases],
        app_identifier: options[:app_identifier],
        username: options[:username]
      }

      precheck_config = FastlaneCore::Configuration.create(Precheck::Options.available_options, precheck_options)
      Precheck.config = precheck_config

      precheck_success = true
      begin
        precheck_success = Precheck::Runner.new.run
      rescue => ex
        UI.error("fastlane precheck just tried to inspect your app's metadata for App Store guideline violations and ran into a problem. We're not sure what the problem was, but precheck failed to finished. You can run it in verbose mode if you want to see the whole error. We'll have a fix out soon 🚀")
        UI.verbose(ex.inspect)
        UI.verbose(ex.backtrace.join("\n"))

        # always report this back, since this is a new tool, we don't want to crash, but we still want to see this
        FastlaneCore::CrashReporter.report_crash(exception: ex)
      end

      return precheck_success
    end

    # Make sure the version on iTunes Connect matches the one in the ipa
    # If not, the new version will automatically be created
    def verify_version
      app_version = options[:app_version]
      UI.message("Making sure the latest version on iTunes Connect matches '#{app_version}' from the ipa file...")

      changed = options[:app].ensure_version!(app_version, platform: options[:platform])

      if changed
        UI.success("Successfully set the version to '#{app_version}'")
      else
        UI.success("'#{app_version}' is the latest version on iTunes Connect")
      end
    end

    # Upload all metadata, screenshots, pricing information, etc. to iTunes Connect
    def upload_metadata
      upload_metadata = UploadMetadata.new
      upload_screenshots = UploadScreenshots.new

      # First, collect all the things for the HTML Report
      screenshots = upload_screenshots.collect_screenshots(options)
      upload_metadata.load_from_filesystem(options)

      # Assign "default" values to all languages
      upload_metadata.assign_defaults(options)

      # Handle app icon / watch icon
      prepare_app_icons(options)

      # Validate
      validate_html(screenshots)

      # Commit
      upload_metadata.upload(options)
      upload_screenshots.upload(options, screenshots)
      UploadPriceTier.new.upload(options)
      UploadAssets.new.upload(options) # e.g. app icon
    end

    # If options[:app_icon]/options[:apple_watch_app_icon]
    # is supplied value/path will be used.
    # If it is unset files (app_icon/watch_icon) exists in
    # the fastlane/metadata/ folder, those will be used
    def prepare_app_icons(options = {})
      return unless options[:metadata_path]

      default_app_icon_path = Dir[File.join(options[:metadata_path], "app_icon.{png,jpg}")].first
      options[:app_icon] ||= default_app_icon_path if default_app_icon_path && File.exist?(default_app_icon_path)

      default_watch_icon_path = Dir[File.join(options[:metadata_path], "watch_icon.{png,jpg}")].first
      options[:apple_watch_app_icon] ||= default_watch_icon_path if default_watch_icon_path && File.exist?(default_watch_icon_path)
    end

    # Upload the binary to iTunes Connect
    def upload_binary
      UI.message("Uploading binary to iTunes Connect")
      if options[:ipa]
        package_path = FastlaneCore::IpaUploadPackageBuilder.new.generate(
          app_id: options[:app].apple_id,
          ipa_path: options[:ipa],
          package_path: "/tmp",
          platform: options[:platform]
        )
      elsif options[:pkg]
        package_path = FastlaneCore::PkgUploadPackageBuilder.new.generate(
          app_id: options[:app].apple_id,
          pkg_path: options[:pkg],
          package_path: "/tmp",
          platform: options[:platform]
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
