describe Spaceship::ConnectAPI::ReviewSubmission do
  let(:mock_tunes_client) { double('tunes_client') }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  before do
    allow(mock_tunes_client).to receive(:team_id).and_return("123")
    allow(mock_tunes_client).to receive(:select_team)
    allow(mock_tunes_client).to receive(:csrf_tokens)
    allow(Spaceship::TunesClient).to receive(:login).and_return(mock_tunes_client)
    Spaceship::ConnectAPI.login(username, password, use_portal: false, use_tunes: true)
  end

  describe '#Spaceship::ConnectAPI' do
    it '#get_review_submission' do
      ConnectAPIStubbing::Tunes.stub_get_review_submission

      response = Spaceship::ConnectAPI.get_review_submission(review_submission_id: "123456789")
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(1)

      model = response.first
      expect(model).to be_an_instance_of(Spaceship::ConnectAPI::ReviewSubmission)

      expect(model.id).to eq("123456789")
      expect(model.platform).to eq(Spaceship::ConnectAPI::Platform::IOS)
      expect(model.state).to eq(Spaceship::ConnectAPI::ReviewSubmission::ReviewSubmissionState::READY_FOR_REVIEW)
      expect(model.submitted_date).to be_nil

      expect(model.app_store_version_for_review.id).to eq("123456789-app-store-version")
      expect(model.items.count).to eq(1)
      expect(model.items.first.id).to eq("123456789-item")
      expect(model.last_updated_by_actor).to be_nil
      expect(model.submitted_by_actor).to be_nil
    end

    it '#patch_review_submission' do
      ConnectAPIStubbing::Tunes.stub_submit_review_submission

      response = Spaceship::ConnectAPI.patch_review_submission(review_submission_id: "123456789", attributes: { submitted: true })
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(1)

      model = response.first
      expect(model).to be_an_instance_of(Spaceship::ConnectAPI::ReviewSubmission)

      expect(model.id).to eq("123456789")
      expect(model.state).to eq(Spaceship::ConnectAPI::ReviewSubmission::ReviewSubmissionState::WAITING_FOR_REVIEW)
    end

    it '#post_review_submission_item' do
      ConnectAPIStubbing::Tunes.stub_create_review_submission_item

      response = Spaceship::ConnectAPI.post_review_submission_item(review_submission_id: "123456789", app_store_version_id: "123456789-app-store-version")
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(1)

      model = response.first
      expect(model).to be_an_instance_of(Spaceship::ConnectAPI::ReviewSubmissionItem)

      expect(model.id).to eq("123456789-item")
      expect(model.state).to eq(Spaceship::ConnectAPI::ReviewSubmission::ReviewSubmissionState::READY_FOR_REVIEW)
    end

  end

  describe "ReviewSubmission object" do
    it 'gets review submission' do
      ConnectAPIStubbing::Tunes.stub_get_review_submission

      review_submission = Spaceship::ConnectAPI::ReviewSubmission.get(review_submission_id: "123456789")
      expect(review_submission.id).to eq("123456789")
    end

    it 'submits the submission for review' do
      ConnectAPIStubbing::Tunes.stub_submit_review_submission

      review_submission = Spaceship::ConnectAPI::ReviewSubmission.new("123456789", [])

      updated_review_submission = review_submission.submit_for_review
      expect(updated_review_submission.id).to eq("123456789")
      expect(updated_review_submission.state).to eq(Spaceship::ConnectAPI::ReviewSubmission::ReviewSubmissionState::WAITING_FOR_REVIEW)
    end

    it 'cancels the submission for review' do
      ConnectAPIStubbing::Tunes.stub_cancel_review_submission

      review_submission = Spaceship::ConnectAPI::ReviewSubmission.new("123456789", [])

      updated_review_submission = review_submission.cancel_submission
      expect(updated_review_submission.id).to eq("123456789")
      expect(updated_review_submission.state).to eq(Spaceship::ConnectAPI::ReviewSubmission::ReviewSubmissionState::CANCELING)
    end

    it 'adds an app store version to the submission items' do
      ConnectAPIStubbing::Tunes.stub_create_review_submission_item

      review_submission = Spaceship::ConnectAPI::ReviewSubmission.new("123456789", [])

      review_submission_item = review_submission.add_app_store_version_to_review_items(app_store_version_id: "123456789-app-store-version")
      expect(review_submission_item.id).to eq("123456789-item")
      expect(review_submission_item.state).to eq(Spaceship::ConnectAPI::ReviewSubmission::ReviewSubmissionState::READY_FOR_REVIEW)
    end
  end
end
