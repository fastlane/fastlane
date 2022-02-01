require 'precheck/options'
require 'precheck/runner'
require 'fastlane_core/configuration/configuration'
require 'fastlane_core/ipa_upload_package_builder'
require 'fastlane_core/pkg_upload_package_builder'
require 'fastlane_core/itunes_transporter'
require 'spaceship'
require_relative 'html_generator'
require_relative 'submit_for_review'
require_relative 'upload_price_tier'
require_relative 'upload_metadata'
require_relative 'upload_screenshots'
require_relative 'sync_screenshots'
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
      if !options[:api_token].nil?
        UI.message('Passing given authorization token for App Store Connect API')
        api_token = Spaceship::ConnectAPI::Token.from_token(options[:api_token])
        Spaceship::ConnectAPI.token = api_token
      elsif (api_token = Spaceship::ConnectAPI::Token.from(hash: options[:api_key], filepath: options[:api_key_path]))
        UI.message("Creating authorization token for App Store Connect API")
        Spaceship::ConnectAPI.token = api_token
      elsif !Spaceship::ConnectAPI.token.nil?
        UI.message("Using existing authorization token for App Store Connect API")
      else
        # Username is now optional since addition of App Store Connect API Key
        # Force asking for username to prompt user if not already set
        options.fetch(:username, force_ask: true)

        # Team selection passed though FASTLANE_TEAM_ID and FASTLANE_TEAM_NAME environment variables
        # Prompts select team if multiple teams and none specified
        UI.message("Login to App Store Connect (#{options[:username]})")
        Spaceship::ConnectAPI.login(options[:username], nil, use_portal: false, use_tunes: true)
        UI.message("Login successful")
      end
    end

    def run
      verify_version if options[:app_version].to_s.length > 0 && !options[:skip_app_version_update]

      # Rejecting before upload meta
      # Screenshots can not be update/deleted if in waiting for review
      reject_version_if_possible if options[:reject_if_possible]

      upload_metadata

      has_binary = (options[:ipa] || options[:pkg])
      if !options[:skip_binary_upload] && !options[:build_number] && has_binary
        upload_binary
      end

      UI.success("Finished the upload to App Store Connect") unless options[:skip_binary_upload]

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
        app_identifier: options[:app_identifier]
      }

      if options[:api_key] || options[:api_key_path]
        if options[:precheck_include_in_app_purchases]
          UI.user_error!("Precheck cannot check In-app purchases with the App Store Connect API Key (yet). Exclude In-app purchases from precheck, disable the precheck step in your build step, or use Apple ID login")
        end

        precheck_options[:api_key] = options[:api_key]
        precheck_options[:api_key_path] = options[:api_key_path]
      else
        precheck_options[:username] = options[:username]
        precheck_options[:platform] = options[:platform]
      end

      precheck_config = FastlaneCore::Configuration.create(Precheck::Options.available_options, precheck_options)
      Precheck.config = precheck_config

      precheck_success = true
      begin
        precheck_success = Precheck::Runner.new.run
      rescue => ex
        UI.error("fastlane precheck just tried to inspect your app's metadata for App Store guideline violations and ran into a problem. We're not sure what the problem was, but precheck failed to finished. You can run it in verbose mode if you want to see the whole error. We'll have a fix out soon 🚀")
        UI.verbose(ex.inspect)
        UI.verbose(ex.backtrace.join("\n"))
      end

      return precheck_success
    end

    # Make sure the version on App Store Connect matches the one in the ipa
    # If not, the new version will automatically be created
    def verify_version
      app_version = options[:app_version]
      UI.message("Making sure the latest version on App Store Connect matches '#{app_version}'...")

      app = Deliver.cache[:app]

      platform = Spaceship::ConnectAPI::Platform.map(options[:platform])
      changed = app.ensure_version!(app_version, platform: platform)

      if changed
        UI.success("Successfully set the version to '#{app_version}'")
      else
        UI.success("'#{app_version}' is the latest version on App Store Connect")
      end
    end

    # Upload all metadata, screenshots, pricing information, etc. to App Store Connect
    def upload_metadata
      upload_metadata = UploadMetadata.new
      upload_screenshots = UploadScreenshots.new

      # First, collect all the things for the HTML Report
      screenshots = upload_screenshots.collect_screenshots(options)
      upload_metadata.load_from_filesystem(options)

      # Assign "default" values to all languages
      upload_metadata.assign_defaults(options)

      # Validate
      validate_html(screenshots)

      # Commit
      upload_metadata.upload(options)

      if options[:sync_screenshots]
        sync_screenshots = SyncScreenshots.new(app: Deliver.cache[:app], platform: Spaceship::ConnectAPI::Platform.map(options[:platform]))
        sync_screenshots.sync(screenshots)
      else
        upload_screenshots.upload(options, screenshots)
      end

      UploadPriceTier.new.upload(options)
    end

    # Upload the binary to App Store Connect
    def upload_binary
      UI.message("Uploading binary to App Store Connect")

      upload_ipa = options[:ipa]
      upload_pkg = options[:pkg]

      # 2020-01-27
      # Only verify platform if if both ipa and pkg exists (for backwards support)
      if upload_ipa && upload_pkg
        upload_ipa = ["ios", "appletvos"].include?(options[:platform])
        upload_pkg = options[:platform] == "osx"
      end

      if upload_ipa
        package_path = FastlaneCore::IpaUploadPackageBuilder.new.generate(
          app_id: Deliver.cache[:app].id,
          ipa_path: options[:ipa],
          package_path: "/tmp",
          platform: options[:platform]
        )
      elsif upload_pkg
        package_path = FastlaneCore::PkgUploadPackageBuilder.new.generate(
          app_id: Deliver.cache[:app].id,
          pkg_path: options[:pkg],
          package_path: "/tmp",
          platform: options[:platform]
        )
      end

      transporter = transporter_for_selected_team
      result = transporter.upload(package_path: package_path, asset_path: upload_ipa || upload_pkg)

      unless result
        transporter_errors = transporter.displayable_errors
        UI.user_error!("Error uploading ipa file: \n #{transporter_errors}")
      end
    end

    def reject_version_if_possible
      app = Deliver.cache[:app]
      platform = Spaceship::ConnectAPI::Platform.map(options[:platform])

      submission = app.get_in_progress_review_submission(platform: platform)
      if submission
        submission.cancel_submission
        UI.message("Review submission cancellation has been requested")

        # An app version won't get removed from review instantly
        # Polling until app version has a state of DEVELOPER_REJECT
        loop do
          version = app.get_edit_app_store_version(platform: platform)
          if version.app_store_state == Spaceship::ConnectAPI::AppStoreVersion::AppStoreState::DEVELOPER_REJECTED
            break
          end

          UI.message("Waiting for cancellation to take effect...")
          sleep(15)
        end

        UI.success("Successfully cancelled previous submission!")
      end
    end

    def submit_for_review
      SubmitForReview.new.submit!(options)
    end

    private

    # If App Store Connect API token, use token.
    # If itc_provider was explicitly specified, use it.
    # If there are multiple teams, infer the provider from the selected team name.
    # If there are fewer than two teams, don't infer the provider.
    def transporter_for_selected_team
      # Use JWT auth
      api_token = Spaceship::ConnectAPI.token
      unless api_token.nil?
        api_token.refresh! if api_token.expired?
        return FastlaneCore::ItunesTransporter.new(nil, nil, false, nil, api_token.text)
      end

      tunes_client = Spaceship::ConnectAPI.client.tunes_client

      generic_transporter = FastlaneCore::ItunesTransporter.new(options[:username], nil, false, options[:itc_provider])
      return generic_transporter unless options[:itc_provider].nil? && tunes_client.teams.count > 1

      begin
        team = tunes_client.teams.find { |t| t['contentProvider']['contentProviderId'].to_s == tunes_client.team_id }
        name = team['contentProvider']['name']
        provider_id = generic_transporter.provider_ids[name]
        UI.verbose("Inferred provider id #{provider_id} for team #{name}.")
        return FastlaneCore::ItunesTransporter.new(options[:username], nil, false, provider_id)
      rescue => ex
        UI.verbose("Couldn't infer a provider short name for team with id #{tunes_client.team_id} automatically: #{ex}. Proceeding without provider short name.")
        return generic_transporter
      end
    end

    def validate_html(screenshots)
      return if options[:force]
      return if options[:skip_metadata] && options[:skip_screenshots]
      HtmlGenerator.new.run(options, screenshots)
    end
  end
end
