require 'spec_helper'

describe Spaceship::AppSubmission do
  before { Spaceship::Tunes.login }

  let(:client) { Spaceship::AppSubmission.client }
  let (:app) { Spaceship::Application.all.first }

  describe "successfully creates a new app submission" do
    it "generates a new app submission from iTunes Connect response" do
      itc_stub_app_submissions
      submission = app.create_submission
      
      expect(submission.application).to eq(app)
      expect(submission.version.version).to eq(app.edit_version.version)
      expect(submission.export_compliance_platform).to eq("ios")
      expect(submission.export_compliance_app_type).to eq("iOS App")
      expect(submission.export_compliance_compliance_required).to eq(true)
      expect(submission.stage).to eq("start")
      expect(submission.url).to eq("https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/apps/898536088/version/submit/start")
    end
    
    it "submits a valid app submission to iTunes Connect" do
      itc_stub_app_submissions
      submission = app.create_submission
      submission.content_rights_contains_third_party_content = true
      submission.content_rights_has_rights = true
      submission.add_id_info_uses_idfa = false
      submission.complete!
      
      expect(submission.submitted_for_review).to eq(true)
    end
    
  end
end
