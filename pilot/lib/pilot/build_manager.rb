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
          options[:changelog] = UI.input("No changelog provided for new build. Please provide a changelog. You can also provide a changelog using the `changelog` option")
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

      UI.success("Successfully uploaded the new binary to iTunes Connect")

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

      if should_update_app_test_information?(options)
        app_test_info = Spaceship::TestFlight::AppTestInfo.find(app_id: build.app_id)
        app_test_info.test_info.feedback_email = options[:beta_app_feedback_email] if options[:beta_app_feedback_email]
        app_test_info.test_info.description = options[:beta_app_description] if options[:beta_app_description]
        begin
          app_test_info.save_for_app!(app_id: build.app_id)
          UI.success("Successfully set the beta_app_feedback_email and/or beta_app_description")
        rescue => ex
          UI.user_error!("Could not set beta_app_feedback_email and/or beta_app_description: #{ex}")
        end
      end

      if should_update_build_information?(options)
        begin
          build.update_build_information!(whats_new: options[:changelog])
          UI.success("Successfully set the changelog for build")
        rescue => ex
          UI.user_error!("Could not set changelog: #{ex}")
        end
      end

      build.auto_notify_enabled = config[:notify_external_testers]

      return if config[:skip_submission]
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

    def should_update_build_information?(options)
      options[:changelog].to_s.length > 0
    end

    def should_update_app_test_information?(options)
      options[:beta_app_description].to_s.length > 0 || options[:beta_app_feedback_email].to_s.length > 0
    end

    def distribute_build(uploaded_build, options)
      UI.message("Distributing new build to testers: #{uploaded_build.train_version} - #{uploaded_build.build_version}")

      # This is where we could add a check to see if encryption is required and has been updated
      uploaded_build.export_compliance.encryption_updated = false

      if options[:groups] || options[:distribute_external]
        uploaded_build.beta_review_info.demo_account_required = options[:demo_account_required] # this needs to be set for iTC to continue
        begin
          uploaded_build.submit_for_testflight_review!
        rescue => ex
          # iTunes Connect currently may 504 on this request even though it manages to get the build in
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
  end
end
