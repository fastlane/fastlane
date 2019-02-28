require 'tmpdir'
require 'terminal-table'
require 'emoji_regex'

require 'fastlane_core/itunes_transporter'
require 'fastlane_core/build_watcher'
require 'fastlane_core/ipa_upload_package_builder'
require_relative 'manager'

module Pilot
  class BuildManager < Manager
    def upload(options)
      start(options)

      options[:changelog] = self.class.sanitize_changelog(options[:changelog]) if options[:changelog]

      UI.user_error!("No ipa file given") unless config[:ipa]

      if options[:changelog].nil? && options[:distribute_external] == true
        if UI.interactive?
          options[:changelog] = UI.input("No changelog provided for new build. You can provide a changelog using the `changelog` option. For now, please provide a changelog here:")
        else
          UI.user_error!("No changelog provided for new build. Please either disable `distribute_external` or provide a changelog using the `changelog` option")
        end
      end

      UI.success("Ready to upload new build to TestFlight (App: #{app.apple_id})...")

      dir = Dir.mktmpdir

      platform = fetch_app_platform
      package_path = FastlaneCore::IpaUploadPackageBuilder.new.generate(app_id: app.apple_id,
                                                                      ipa_path: config[:ipa],
                                                                  package_path: dir,
                                                                      platform: platform)

      transporter = FastlaneCore::ItunesTransporter.new(options[:username], nil, false, options[:itc_provider])
      result = transporter.upload(app.apple_id, package_path)

      unless result
        UI.user_error!("Error uploading ipa file, for more information see above")
      end

      UI.success("Successfully uploaded the new binary to App Store Connect")

      if config[:skip_waiting_for_build_processing]
        UI.important("Skip waiting for build processing")
        UI.important("This means that no changelog will be set and no build will be distributed to testers")
        return
      end

      UI.message("If you want to skip waiting for the processing to be finished, use the `skip_waiting_for_build_processing` option")
      app_version = FastlaneCore::IpaFileAnalyser.fetch_app_version(config[:ipa])
      app_build = FastlaneCore::IpaFileAnalyser.fetch_app_build(config[:ipa])
      latest_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app_id: app.apple_id, platform: platform, train_version: app_version, build_version: app_build, poll_interval: config[:wait_processing_interval], strict_build_watch: config[:wait_for_uploaded_build])

      unless latest_build.train_version == app_version && latest_build.build_version == app_build
        UI.important("Uploaded app #{app_version} - #{app_build}, but received build #{latest_build.train_version} - #{latest_build.build_version}. If you want to wait for uploaded build to be finished processing, use the `wait_for_uploaded_build` option")
      end

      distribute(options, build: latest_build)
    end

    def distribute(options, build: nil)
      start(options)
      if config[:apple_id].to_s.length == 0 && config[:app_identifier].to_s.length == 0
        config[:app_identifier] = UI.input("App Identifier: ")
      end

      build ||= Spaceship::TestFlight::Build.latest(app_id: app.apple_id, platform: fetch_app_platform)
      if build.nil?
        UI.user_error!("No build to distribute!")
      end

      # Update beta app meta info
      # 1. Demo account required
      # 2. App info
      # 3. Localized app  info
      # 4. Localized build info
      # 5. Auto notify enabled with config[:notify_external_testers]
      update_beta_app_meta(options, build)

      return if config[:skip_submission]
      if options[:reject_build_waiting_for_review]
        waiting_for_review_build = Spaceship::TestFlight::Build.all_waiting_for_review(app_id: build.app_id, platform: fetch_app_platform).first
        unless waiting_for_review_build.nil?
          UI.important("Another build is already in review. Going to expire that build and submit the new one.")
          UI.important("Expiring build: #{waiting_for_review_build.train_version} - #{waiting_for_review_build.build_version}")
          waiting_for_review_build.expire!
          UI.success("Expired previous build: #{waiting_for_review_build.train_version} - #{waiting_for_review_build.build_version}")
        end
      end
      distribute_build(build, options)
      type = options[:distribute_external] ? 'External' : 'Internal'
      UI.success("Successfully distributed build to #{type} testers 🚀")
    end

    def list(options)
      start(options)
      if config[:apple_id].to_s.length == 0 && config[:app_identifier].to_s.length == 0
        config[:app_identifier] = UI.input("App Identifier: ")
      end

      platform = fetch_app_platform(required: false)
      builds = app.all_processing_builds(platform: platform) + app.builds(platform: platform)
      # sort by upload_date
      builds.sort! { |a, b| a.upload_date <=> b.upload_date }
      rows = builds.collect { |build| describe_build(build) }

      puts(Terminal::Table.new(
             title: "#{app.name} Builds".green,
             headings: ["Version #", "Build #", "Installs"],
             rows: FastlaneCore::PrintTable.transform_output(rows)
      ))
    end

    def update_beta_app_meta(options, build)
      # Setting account required wth AppStore Connect API
      update_review_detail(build.app_id, { demo_account_required: options[:demo_account_required] })

      if should_update_beta_app_review_info(options)
        update_review_detail(build.app_id, options[:beta_app_review_info])
      end

      if should_update_localized_app_information?(options)
        update_localized_app_review(build.app_id, options[:localized_app_info])
      elsif should_update_app_test_information?(options)
        default_info = {}
        default_info[:feedback_email] = options[:beta_app_feedback_email] if options[:beta_app_feedback_email]
        default_info[:description] = options[:beta_app_description] if options[:beta_app_description]
        begin
          update_localized_app_review(build.app_id, {}, default_info: default_info)
          UI.success("Successfully set the beta_app_feedback_email and/or beta_app_description")
        rescue => ex
          UI.user_error!("Could not set beta_app_feedback_email and/or beta_app_description: #{ex}")
        end
      end

      if should_update_localized_build_information?(options)
        update_localized_build_review(build, options[:localized_build_info])
      elsif should_update_build_information?(options)
        begin
          update_localized_build_review(build, {}, default_info: { whats_new: options[:changelog] })
          UI.success("Successfully set the changelog for build")
        rescue => ex
          UI.user_error!("Could not set changelog: #{ex}")
        end
      end

      update_build_beta_details(build, {
        auto_notify_enabled: options[:notify_external_testers]
      })
    end

    def self.truncate_changelog(changelog)
      max_changelog_length = 4000
      if changelog && changelog.length > max_changelog_length
        original_length = changelog.length
        bottom_message = "..."
        changelog = "#{changelog[0...max_changelog_length - bottom_message.length]}#{bottom_message}"
        UI.important("Changelog has been truncated since it exceeds Apple's #{max_changelog_length} character limit. It currently contains #{original_length} characters.")
      end
      changelog
    end

    def self.strip_emoji(changelog)
      if changelog && changelog =~ EmojiRegex::Regex
        changelog.gsub!(EmojiRegex::Regex, "")
        UI.important("Emoji symbols have been removed from the changelog, since they're not allowed by Apple.")
      end
      changelog
    end

    def self.sanitize_changelog(changelog)
      changelog = strip_emoji(changelog)
      truncate_changelog(changelog)
    end

    private

    def describe_build(build)
      row = [build.train_version,
             build.build_version,
             build.install_count]

      return row
    end

    def should_update_beta_app_review_info(options)
      !options[:beta_app_review_info].nil?
    end

    def should_update_build_information?(options)
      options[:changelog].to_s.length > 0
    end

    def should_update_app_test_information?(options)
      options[:beta_app_description].to_s.length > 0 || options[:beta_app_feedback_email].to_s.length > 0
    end

    def should_update_localized_app_information?(options)
      !options[:localized_app_info].nil?
    end

    def should_update_localized_build_information?(options)
      !options[:localized_build_info].nil?
    end

    def distribute_build(uploaded_build, options)
      UI.message("Distributing new build to testers: #{uploaded_build.train_version} - #{uploaded_build.build_version}")

      # This is where we could add a check to see if encryption is required and has been updated
      uploaded_build.export_compliance.encryption_updated = false

      if options[:groups] || options[:distribute_external]
        begin
          uploaded_build.submit_for_testflight_review!
        rescue => ex
          # App Store Connect currently may 504 on this request even though it manages to get the build in
          # the approved state, this is a temporary workaround.
          raise ex unless ex.to_s.include?("504")
          UI.message("Submitting the build for review timed out, trying to recover.")
          updated_build = Spaceship::TestFlight::Build.find(app_id: uploaded_build.app_id, build_id: uploaded_build.id)
          raise ex unless updated_build.approved?
        end
      end

      if options[:groups]
        groups = Spaceship::TestFlight::Group.filter_groups(app_id: uploaded_build.app_id) do |group|
          options[:groups].include?(group.name)
        end
        groups.each do |group|
          uploaded_build.add_group!(group)
        end
      end

      if options[:distribute_external]
        external_group = Spaceship::TestFlight::Group.default_external_group(app_id: uploaded_build.app_id)
        uploaded_build.add_group!(external_group) unless external_group.nil?

        if external_group.nil? && options[:groups].nil?
          UI.user_error!("You must specify at least one group using the `:groups` option to distribute externally")
        end
      else # distribute internally
        # in case any changes to export_compliance are required
        if uploaded_build.export_compliance_missing?
          uploaded_build.save!
        end
      end

      true
    end

    def update_review_detail(app_id, info)
      info = info.collect { |k, v| [k.to_sym, v] }.to_h

      attributes = {}
      attributes[:contactEmail] = info[:contact_email] if info.key?(:contact_email)
      attributes[:contactFirstName] = info[:contact_first_name] if info.key?(:contact_first_name)
      attributes[:contactLastName] = info[:contact_last_name] if info.key?(:contact_last_name)
      attributes[:contactPhone] = info[:contact_phone] if info.key?(:contact_phone)
      attributes[:demoAccountName] = info[:demo_account_name] if info.key?(:demo_account_name)
      attributes[:demoAccountPassword] = info[:demo_account_password] if info.key?(:demo_account_password)
      attributes[:demoAccountRequired] = info[:demo_account_required] if info.key?(:demo_account_required)
      attributes[:notes] = info[:notes] if info.key?(:notes)

      client = Spaceship::ConnectAPI::Base.client
      client.patch_beta_app_review_detail(app_id: app_id, attributes: attributes)
    end

    def update_localized_app_review(app_id, info_by_lang, default_info: nil)
      info_by_lang = info_by_lang.collect { |k, v| [k.to_sym, v] }.to_h

      if default_info
        info_by_lang.delete(:default)
      else
        default_info = info_by_lang.delete(:default)
      end

      # Initialize hash of lang codes
      langs_localization_ids = {}

      # Validate locales exist
      client = Spaceship::ConnectAPI::Base.client
      localizations = client.get_beta_app_localizations(filter: { app: app_id })
      localizations.each do |localization|
        localization_id = localization["id"]
        attributes = localization["attributes"]
        locale = attributes["locale"]

        langs_localization_ids[locale.to_sym] = localization_id
      end

      # Create or update localized app review info
      langs_localization_ids.each do |lang_code, localization_id|
        info = info_by_lang[lang_code]

        info = default_info unless info
        update_localized_app_review_for_lang(app_id, localization_id, lang_code, info) if info
      end
    end

    def update_localized_app_review_for_lang(app_id, localization_id, locale, info)
      attributes = {}
      attributes[:feedbackEmail] = info[:feedback_email] if info.key?(:feedback_email)
      attributes[:marketingUrl] = info[:marketing_url] if info.key?(:marketing_url)
      attributes[:privacyPolicyUrl] = info[:privacy_policy_url] if info.key?(:privacy_policy_url)
      attributes[:tvOsPrivacyPolicy] = info[:tv_os_privacy_policy_url] if info.key?(:tv_os_privacy_policy_url)
      attributes[:description] = info[:description] if info.key?(:description)

      client = Spaceship::ConnectAPI::Base.client
      if localization_id
        client.patch_beta_app_localizations(localization_id: localization_id, attributes: attributes)
      else
        attributes[:locale] = locale if locale
        client.post_beta_app_localizations(app_id: app_id, attributes: attributes)
      end
    end

    def update_localized_build_review(build, info_by_lang, default_info: nil)
      resp = Spaceship::ConnectAPI::Base.client.get_builds(filter: { expired: false, processingState: "PROCESSING,VALID", version: build.build_version })
      build_id = resp.first["id"]

      info_by_lang = info_by_lang.collect { |k, v| [k.to_sym, v] }.to_h

      if default_info
        info_by_lang.delete(:default)
      else
        default_info = info_by_lang.delete(:default)
      end

      # Initialize hash of lang codes
      langs_localization_ids = {}

      # Validate locales exist
      client = Spaceship::ConnectAPI::Base.client
      localizations = client.get_beta_build_localizations(filter: { build: build_id })
      localizations.each do |localization|
        localization_id = localization["id"]
        attributes = localization["attributes"]
        locale = attributes["locale"]

        langs_localization_ids[locale.to_sym] = localization_id
      end

      # Create or update localized app review info
      langs_localization_ids.each do |lang_code, localization_id|
        info = info_by_lang[lang_code]

        info = default_info unless info
        update_localized_build_review_for_lang(build_id, localization_id, lang_code, info) if info
      end
    end

    def update_localized_build_review_for_lang(build_id, localization_id, locale, info)
      attributes = {}
      attributes[:whatsNew] = info[:whats_new] if info.key?(:whats_new)

      client = Spaceship::ConnectAPI::Base.client
      if localization_id
        client.patch_beta_build_localizations(localization_id: localization_id, attributes: attributes)
      else
        attributes[:locale] = locale if locale
        client.post_beta_build_localizations(build_id: build_id, attributes: attributes)
      end
    end

    def update_build_beta_details(build, info)
      client = Spaceship::ConnectAPI::Base.client

      resp = client.get_builds(filter: { expired: false, processingState: "PROCESSING,VALID", version: build.build_version })
      build_id = resp.first["id"]

      resp = client.get_build_beta_details(filter: { build: build_id })
      build_beta_details_id = resp.first["id"]

      attributes = {}
      attributes[:autoNotifyEnabled] = info[:auto_notify_enabled] if info.key?(:auto_notify_enabled)

      client.patch_build_beta_details(build_beta_details_id: build_beta_details_id, attributes: attributes)
    end
  end
end
