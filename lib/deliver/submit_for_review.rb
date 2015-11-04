module Deliver
  class SubmitForReview
    def submit!(options)
      app = options[:app]
      select_build(options)

      Helper.log.info "Submitting the app for review..."
      submission = app.create_submission

      # Set app submission information
      # Default Values
      submission.content_rights_contains_third_party_content = false
      submission.content_rights_has_rights = true
      submission.add_id_info_uses_idfa = false

      # User Values
      if options[:submission_information]
        raise "`submission_information` must be a hash" unless options[:submission_information].kind_of?(Hash)
        options[:submission_information].each do |key, value|
          Helper.log.info "Setting '#{key}' to '#{value}'..."
          submission.send("#{key}=", value)
        end
      end

      # Finalize app submission
      submission.complete!

      Helper.log.info "Successfully submitted the app for review!".green
    end

    def select_build(options)
      Helper.log.info "Selecting the latest build..."
      app = options[:app]
      v = app.edit_version
      build = wait_for_build(app)

      Helper.log.info "Selecting build #{build.train_version} (#{build.build_version})..."

      v.select_build(build)
      v.save!

      Helper.log.info "Successfully selected build".green
    end

    def wait_for_build(app)
      raise "Could not find app with app identifier #{WatchBuild.config[:app_identifier]}".red unless app

      start = Time.now

      loop do
        build = find_build(app)
        return build if build.processing == false

        Helper.log.info "Waiting iTunes Connect processing for build #{build.train_version} (#{build.build_version})... this might take a while..."
        if (Time.now - start) > (60 * 5)
          Helper.log.info ""
          Helper.log.info "You can tweet: \"iTunes Connect #iosprocessingtime #{((Time.now - start) / 60).round} minutes\""
        end
        sleep 30
      end
      nil
    end

    def find_build(app)
      build = nil
      app.latest_version.candidate_builds.each do |b|
        if !build or b.upload_date > build.upload_date
          build = b
        end
      end

      unless build
        Helper.log.fatal app.latest_version.candidate_builds
        raise "Could not find build".red
      end

      return build
    end
  end
end
