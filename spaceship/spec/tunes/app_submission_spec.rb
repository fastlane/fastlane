describe Spaceship::AppSubmission do
  before { Spaceship::Tunes.login }

  let(:client) { Spaceship::AppSubmission.client }
  let(:app) { Spaceship::Application.all.first }

  describe "successfully creates a new app submission" do
    it "generates a new app submission from iTunes Connect response" do
      TunesStubbing.itc_stub_app_submissions
      submission = app.create_submission

      expect(submission.application).to eq(app)
      expect(submission.version.version).to eq(app.edit_version.version)
      expect(submission.export_compliance_platform).to eq("ios")
      expect(submission.export_compliance_app_type).to eq("iOS App")
      expect(submission.export_compliance_compliance_required).to eq(true)
    end

    it "submits a valid app submission to iTunes Connect" do
      TunesStubbing.itc_stub_app_submissions
      submission = app.create_submission
      submission.content_rights_contains_third_party_content = true
      submission.content_rights_has_rights = true
      submission.add_id_info_uses_idfa = false
      submission.complete!

      expect(submission.submitted_for_review).to eq(true)
    end

    it "sets automatically the limitsTracking value for the usesIdfa" do
      TunesStubbing.itc_stub_app_submissions
      submission = app.create_submission
      submission.content_rights_contains_third_party_content = true
      submission.content_rights_has_rights = true
      submission.add_id_info_uses_idfa = true
      submission.complete!

      expect(submission.raw_data["adIdInfo"]["limitsTracking"]["value"]).to eq(true)
    end

    it "raises an error when submitting an app that has validation errors" do
      TunesStubbing.itc_stub_app_submissions_invalid

      expect do
        app.create_submission
      end.to raise_error("[German]: The App Name you entered has already been used. [English]: The App Name you entered has already been used. You must provide an address line. There are errors on the page and for 2 of your localizations.")
    end

    it "raises an error when submitting an app that is already in review" do
      TunesStubbing.itc_stub_app_submissions_already_submitted
      submission = app.create_submission
      submission.content_rights_contains_third_party_content = true
      submission.content_rights_has_rights = true
      submission.add_id_info_uses_idfa = false

      expect do
        submission.complete!
      end.to raise_exception("Problem processing review submission.")
      expect(submission.submitted_for_review).to eq(false)
    end
  end
end
