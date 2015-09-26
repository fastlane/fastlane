module Deliver
  class SubmitForReview
    def submit!(options)
      Helper.log.info "Submitting the app for review..."
      app = options[:app]

      submission = app.create_submission

      # Set app submission information
      submission.content_rights_contains_third_party_content = false
      submission.content_rights_has_rights = true
      submission.add_id_info_uses_idfa = false

      # Finalize app submission
      submission.complete!

      Helper.log.info "Successfully submitted the app for review!".green
    end
  end
end
