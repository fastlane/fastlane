describe Spaceship::ConnectAPI::ReviewSubmissionItem do
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
    it '#get_review_submission_items' do
      ConnectAPIStubbing::Tunes.stub_get_review_submission_items

      response = Spaceship::ConnectAPI.get_review_submission_items(review_submission_id: "123456789")
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(1)

      model = response.first
      expect(model).to be_an_instance_of(Spaceship::ConnectAPI::ReviewSubmissionItem)

      expect(model.id).to eq("123456789-item")
      expect(model.state).to eq(Spaceship::ConnectAPI::ReviewSubmission::ReviewSubmissionState::READY_FOR_REVIEW)

      expect(model.app_store_version.id).to eq("123456789-app-store-version")
      expect(model.app_store_version_experiment).to be_nil
      expect(model.app_store_product_page_version).to be_nil
      expect(model.app_event).to be_nil
    end
  end

  describe "ReviewSubmissionItem object" do
    it 'gets all items for a review submission' do
      ConnectAPIStubbing::Tunes.stub_get_review_submission_items

      review_submission_items = Spaceship::ConnectAPI::ReviewSubmissionItem.all(review_submission_id: "123456789")
      expect(review_submission_items.count).to eq(1)
      expect(review_submission_items.first.id).to eq("123456789-item")
    end
  end
end
