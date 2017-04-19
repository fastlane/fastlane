require 'tmpdir'

module Pilot
  class BuildManager < Manager
    def upload(options)
      start(options)

      options[:changelog] = self.class.truncate_changelog(options[:changelog]) if options[:changelog]

      UI.user_error!("No ipa file given") unless config[:ipa]

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
      latest_build = FastlaneCore::BuildWatcher.wait_for_build_processing_to_be_complete(app.apple_id, platform: platform)

      distribute(options, latest_build)
    end

    def distribute(options, build)
      start(options)
      if config[:apple_id].to_s.length == 0 and config[:app_identifier].to_s.length == 0
        config[:app_identifier] = UI.input("App Identifier: ")
      end

      unless config[:update_build_info_on_upload]
        if should_update_build_information(options)
          build.update_build_information!(whats_new: options[:changelog], description: options[:beta_app_description], feedback_email: options[:beta_app_feedback_email])
          UI.success "Successfully set the changelog and/or description for build"
        end
      end

      return if config[:skip_submission]
      distribute_build(build, options)
      type = options[:distribute_external] ? 'External' : 'Internal'
      UI.success("Successfully distributed build to #{type} testers 🚀")
    end

    def list(options)
      start(options)
      if config[:apple_id].to_s.length == 0 and config[:app_identifier].to_s.length == 0
        config[:app_identifier] = UI.input("App Identifier: ")
      end

      platform = fetch_app_platform(required: false)
      builds = app.all_processing_builds(platform: platform) + app.builds(platform: platform)
      # sort by upload_date
      builds.sort! { |a, b| a.upload_date <=> b.upload_date }
      rows = builds.collect { |build| describe_build(build) }

      puts Terminal::Table.new(
        title: "#{app.name} Builds".green,
        headings: ["Version #", "Build #", "Testing", "Installs", "Sessions"],
        rows: FastlaneCore::PrintTable.transform_output(rows)
      )
    end

    def self.truncate_changelog(changelog)
      max_changelog_length = 4000
      if changelog && changelog.length > max_changelog_length
        original_length = changelog.length
        bottom_message = "..."
        changelog = "#{changelog[0...max_changelog_length - bottom_message.length]}#{bottom_message}"
        UI.important "Changelog has been truncated since it exceeds Apple's #{max_changelog_length} character limit. It currently contains #{original_length} characters."
      end
      return changelog
    end

    private

    def describe_build(build)
      row = [build.train_version,
             build.build_version,
             build.testing_status,
             build.install_count,
             build.session_count]

      return row
    end

    def should_update_build_information(options)
      options[:changelog].to_s.length > 0 or options[:beta_app_description].to_s.length > 0 or options[:beta_app_feedback_email].to_s.length > 0
    end

    def distribute_build(uploaded_build, options)
      UI.message("Distributing new build to testers: #{uploaded_build.train_version} - #{uploaded_build.build_version}")

      # TODO: do something about encryption and demo account
      uploaded_build.export_compliance.encryption_updated = false
      uploaded_build.beta_review_info.demo_account_required = false
      uploaded_build.submit_for_review!

      if options[:distribute_external]
        external_group = TestFlight::Group.default_external_group(uploaded_build.app_id)

        if external_group.nil? && options[:groups].nil?
          UI.user_error!("You must specify at least one group using the `:groups` option to distribute externally")
        end

        uploaded_build.add_group!(external_group)
      end

      if options[:groups]
        groups = Group.filter_groups(uploaded_build.app_id) do |group|
          options[:groups].include?(group.name)
        end
        groups.each do |group|
          uploaded_build.add_group!(group)
        end
      end

      true
    end
  end
end
