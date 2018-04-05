require_relative 'module'

module Deliver
  class SubmitForReview
    def submit!(options)
      app = options[:app]
      select_build(options)

      UI.message("Submitting the app for review...")
      submission = app.create_submission

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

    def select_build(options)
      app = options[:app]
      v = app.edit_version

      if options[:build_number] && options[:build_number] != "latest"
        UI.message("Selecting existing build-number: #{options[:build_number]}")
        build = v.candidate_builds.detect { |a| a.build_version == options[:build_number] }
        unless build
          UI.user_error!("Build number: #{options[:build_number]} does not exist")
        end
      else
        UI.message("Selecting the latest build...")
        build = wait_for_build(app)
      end
      UI.message("Selecting build #{build.train_version} (#{build.build_version})...")

      v.select_build(build)
      v.save!

      UI.success("Successfully selected build")
    end

    def wait_for_build(app)
      UI.user_error!("Could not find app with app identifier") unless app

      start = Time.now

      loop do
        build = find_build(app.latest_version.candidate_builds)
        return build if build.processing == false

        UI.message("Waiting iTunes Connect processing for build #{build.train_version} (#{build.build_version})... this might take a while...")
        if (Time.now - start) > (60 * 5)
          UI.message("")
          UI.message("You can tweet: \"iTunes Connect #iosprocessingtime #{((Time.now - start) / 60).round} minutes\"")
        end
        sleep(30)
      end
      nil
    end

    def find_build(candidate_builds)
      if (candidate_builds || []).count == 0
        UI.user_error!("Could not find any available candidate builds on iTunes Connect to submit")
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
