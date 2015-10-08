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

      start = Time.now

      loop do
        processing = v.candidate_builds.find_all(&:processing)
        break if processing.count == 0

        Helper.log.info "Waiting iTunes Connect processing... this might take a while..."
        if (Time.now - start) > (60 * 5)
          Helper.log.info ""
          Helper.log.info "You can tweet: \"iTunes Connect #iosprocessingtime #{((Time.now - start) / 60).round} minutes\""
        end
        sleep 30
      end

      build = nil
      v.candidate_builds.each do |b|
        if !build or b.upload_date > build.upload_date
          build = b
        end
      end

      unless build
        Helper.log.fatal v.candidate_builds
        raise "Could not find build to select".red
      end

      Helper.log.info "Selecting build #{build.train_version} (#{build.build_version})..."

      v.select_build(build)
      v.save!

      Helper.log.info "Successfully selected build".green
    end
  end
end
