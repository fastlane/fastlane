module Pilot
  class BuildManager < Manager
    def upload(options)
      start(options)

      UI.user_error!("No ipa file given") unless config[:ipa]

      UI.success("Ready to upload new build to TestFlight (App: #{app.apple_id})...")

      plist = FastlaneCore::IpaFileAnalyser.fetch_info_plist_file(config[:ipa]) || {}
      platform = plist["DTPlatformName"]
      platform = "ios" if platform == "iphoneos" # via https://github.com/fastlane/spaceship/issues/247
      package_path = FastlaneCore::IpaUploadPackageBuilder.new.generate(app_id: app.apple_id,
                                                                      ipa_path: config[:ipa],
                                                                  package_path: "/tmp",
                                                                      platform: platform)

      transporter = FastlaneCore::ItunesTransporter.new(options[:username], nil, false, options[:itc_provider])
      result = transporter.upload(app.apple_id, package_path)

      unless result
        UI.user_error!("Error uploading ipa file, for more information see above")
      end

      UI.message("Successfully uploaded the new binary to iTunes Connect")

      if config[:skip_waiting_for_build_processing]
        UI.important("Skip waiting for build processing")
        UI.important("This means that no changelog will be set and no build will be distributed to testers")
        return
      end

      UI.message("If you want to skip waiting for the processing to be finished, use the `skip_waiting_for_build_processing` option")
      uploaded_build = wait_for_processing_build # this might take a while

      distribute(options, uploaded_build)
    end

    def distribute(options, build = nil)
      start(options)
      if config[:apple_id].to_s.length == 0 and config[:app_identifier].to_s.length == 0
        config[:app_identifier] = UI.input("App Identifier: ")
      end

      if build.nil?
        builds = app.all_processing_builds + app.builds
        # sort by upload_date
        builds.sort! { |a, b| a.upload_date <=> b.upload_date }
        build = builds.last
        if build.nil?
          UI.user_error!("No builds found.")
          return
        end
        if build.processing
          UI.user_error!("Build #{build.train_version}(#{build.build_version}) is still processing.")
          return
        end
        if build.testing_status == "External"
          UI.user_error!("Build #{build.train_version}(#{build.build_version}) has already been distributed.")
          return
        end

        UI.message("Distributing build #{build.train_version}(#{build.build_version}) from #{build.testing_status} -> External")
      end

      # First, set the changelog and/or description if necessary
      if options[:changelog].to_s.length > 0 or options[:beta_app_description].to_s.length > 0 or options[:beta_app_feedback_email].to_s.length > 0
        build.update_build_information!(whats_new: options[:changelog], description: options[:beta_app_description], feedback_email: options[:beta_app_feedback_email])
        UI.success "Successfully set the changelog and/or description for build"
      end

      return if config[:skip_submission]
      distribute_build(build, options)
      UI.message("Successfully distributed build to beta testers 🚀")
    end

    def list(options)
      start(options)
      if config[:apple_id].to_s.length == 0 and config[:app_identifier].to_s.length == 0
        config[:app_identifier] = UI.input("App Identifier: ")
      end

      builds = app.all_processing_builds + app.builds
      # sort by upload_date
      builds.sort! { |a, b| a.upload_date <=> b.upload_date }
      rows = builds.collect { |build| describe_build(build) }

      puts Terminal::Table.new(
        title: "#{app.name} Builds".green,
        headings: ["Version #", "Build #", "Testing", "Installs", "Sessions"],
        rows: rows
      )
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

    # This method will takes care of checking for the processing builds every few seconds
    # @return [Build] The build that we just uploaded
    def wait_for_processing_build
      # the upload date of the new buid
      # we use it to identify the build
      start = Time.now
      wait_processing_interval = config[:wait_processing_interval].to_i
      latest_build = nil
      UI.message("Waiting for iTunes Connect to process the new build")
      loop do
        sleep(wait_processing_interval)

        # before we look for processing builds, we need to ensure that there
        #  is a build train for this application; new applications don't
        #  build trains right away, and if we don't do this check, we will
        #  get break out of this loop and then generate an error later when we
        #  have a nil build
        if app.build_trains.count == 0
          UI.message("New application; waiting for build train to appear on iTunes Connect")
        else
          builds = app.all_processing_builds
          break if builds.count == 0
          latest_build = builds.last
          UI.message("Waiting for iTunes Connect to finish processing the new build (#{latest_build.train_version} - #{latest_build.build_version})")
        end
      end

      UI.user_error!("Error receiving the newly uploaded binary, please check iTunes Connect") if latest_build.nil?
      full_build = nil

      while full_build.nil? || full_build.processing
        # The build's processing state should go from true to false, and be done. But sometimes it goes true -> false ->
        # true -> false, where the second true is transient. This causes a spurious failure. Find build by build_version
        # and ensure it's not processing before proceeding - it had to have already been false before, to get out of the
        # previous loop.
        build_train = app.build_trains[latest_build.train_version]
        builds = build_train ? build_train.builds : []
        full_build = builds.find do |b|
          b.build_version == latest_build.build_version
        end

        UI.message("Waiting for iTunes Connect to finish processing the new build (#{latest_build.train_version} - #{latest_build.build_version})")
        sleep(wait_processing_interval)
      end

      if full_build && !full_build.processing && full_build.valid
        minutes = ((Time.now - start) / 60).round
        UI.success("Successfully finished processing the build")
        UI.message("You can now tweet: ")
        UI.important("iTunes Connect #iosprocessingtime #{minutes} minutes")
        return full_build
      else
        UI.user_error!("Error: Seems like iTunes Connect didn't properly pre-process the binary")
      end
    end

    def distribute_build(uploaded_build, options)
      UI.message("Distributing new build to testers")

      # Submit for review before external testflight is available
      if options[:distribute_external]
        uploaded_build.client.submit_testflight_build_for_review!(
          app_id: uploaded_build.build_train.application.apple_id,
          train: uploaded_build.build_train.version_string,
          build_number: uploaded_build.build_version,
          platform: uploaded_build.platform
        )
      end

      # Submit for beta testing
      type = options[:distribute_external] ? 'external' : 'internal'
      uploaded_build.build_train.update_testing_status!(true, type, uploaded_build)
      return true
    end
  end
end
