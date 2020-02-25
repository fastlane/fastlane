require_relative 'module'

module Deliver
  class SubmitForReview
    def submit!(options)
      app = options[:app]
      select_build(options)

      UI.message("Submitting the app for review...")
      submission = app.create_submission(platform: options[:platform])

      # Set app submission information
      # Default Values
      submission.content_rights_contains_third_party_content = false
      submission.content_rights_has_rights = true
      submission.add_id_info_uses_idfa = false

      # User Values
      if options[:submission_information]
        options[:submission_information].each do |key, value|
          UI.message("Setting '#{key}' to '#{value}'...")
          submission.send("#{key}=", value)
        end
      end

      # Finalize app submission
      submission.complete!

      UI.success("Successfully submitted the app for review!")
    end

    private def select_build(options)
      app = options[:app]
      app_version = options[:app_version]
      v = app.edit_version(platform: options[:platform])

      if options[:build_number] && options[:build_number] != "latest"
        UI.message("Selecting existing build-number: #{options[:build_number]}")
        build = v.candidate_builds.detect { |a| a.build_version == options[:build_number] }
        unless build
          UI.user_error!("Build number: #{options[:build_number]} does not exist")
        end
      else
        UI.message("Selecting the latest build...")
        build = wait_for_build(app, app_version)
      end
      UI.message("Selecting build #{app_version} (#{build.build_version})...")

      v.select_build(build)
      v.save!

      UI.success("Successfully selected build")
    end

    def wait_for_build(app, app_version)
      UI.user_error!("Could not find app with app identifier") unless app

      start = Time.now
      build = nil

      use_latest_version = app_version.nil?

      loop do
        # Sometimes candidate_builds don't appear immediately after submission
        # Wait for candidate_builds to appear on App Store Connect
        # Issue https://github.com/fastlane/fastlane/issues/10411
        if use_latest_version
          candidate_builds = app.latest_version.candidate_builds
        else
          candidate_builds = app.tunes_all_builds_for_train(train: app_version)
        end
        if (candidate_builds || []).count == 0
          UI.message("Waiting for candidate builds to appear...")
          if (Time.now - start) > (60 * 5)
            UI.user_error!("Could not find any available candidate builds on App Store Connect to submit")
          else
            sleep(30)
            next
          end
        end

        latest_build = find_build(candidate_builds)

        # if the app version isn't present in the hash (could happen if we are waiting for submission, but didn't provide
        # it explicitly and no ipa was passed to grab it from), then fall back to the best guess, which is the train_version
        # of the most recently uploaded build
        app_version ||= latest_build.train_version

        # Sometimes latest build will disappear and a different build would get selected
        # Only set build if no latest build found or if same build versions as previously fetched build
        # Issue: https://github.com/fastlane/fastlane/issues/10945
        if build.nil? || (latest_build && latest_build.build_version == build.build_version && latest_build.train_version == app_version)
          build = latest_build
        end

        return build if build && build.processing == false

        if build
          UI.message("Waiting App Store Connect processing for build #{app_version} (#{build.build_version})... this might take a while...")
        else
          UI.message("Waiting App Store Connect processing for build... this might take a while...")
        end

        if (Time.now - start) > (60 * 5)
          UI.message("")
          UI.message("You can tweet: \"App Store Connect #iosprocessingtime #{((Time.now - start) / 60).round} minutes\"")
        end
        sleep(30)
      end
      nil
    end

    def find_build(candidate_builds)
      if (candidate_builds || []).count == 0
        UI.user_error!("Could not find any available candidate builds on App Store Connect to submit")
      end

      build = candidate_builds.first
      candidate_builds.each do |b|
        if b.upload_date > build.upload_date
          build = b
        end
      end

      return build
    end
  end
end
