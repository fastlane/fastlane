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

    describe '#items_only?' do
      let(:client) { double('connect_api_client') }
      let(:review_submission) { Spaceship::ConnectAPI::ReviewSubmission.new("123456789", []) }

      def response_with_items(items)
        double('response', body: { "data" => items })
      end

      it 'requests app store version linkage and recognizes an explicit null' do
        item = {
          "type" => "reviewSubmissionItems",
          "id" => "page-item",
          "relationships" => {
            "appStoreVersion" => { "data" => nil },
            "appCustomProductPageVersion" => {
              "data" => { "type" => "appCustomProductPageVersions", "id" => "page-version" }
            }
          }
        }
        request = stub_request(:get, "https://appstoreconnect.apple.com/iris/v1/reviewSubmissions/123456789/items").
                  with(query: { "include" => "appStoreVersion,appCustomProductPageVersion" }).
                  to_return(
                    status: 200,
                    body: {
                      "data" => [item],
                      "included" => [{
                        "type" => "appCustomProductPageVersions",
                        "id" => "page-version"
                      }]
                    }.to_json,
                    headers: { 'Content-Type' => 'application/json' }
                  )

        expect(review_submission.items_only?).to eq(true)
        expect(request).to have_been_requested.once
      end

      it 'checks app store version linkage on every response page' do
        first_url = "https://appstoreconnect.apple.com/iris/v1/reviewSubmissions/123456789/items"
        next_url = "#{first_url}?cursor=next&include=appStoreVersion%2CappCustomProductPageVersion"
        first_request = stub_request(:get, first_url).
                        with(query: { "include" => "appStoreVersion,appCustomProductPageVersion" }).
                        to_return(
                          status: 200,
                          body: {
                            "data" => [{
                              "type" => "reviewSubmissionItems",
                              "id" => "page-item",
                              "relationships" => { "appStoreVersion" => { "data" => nil } }
                            }],
                            "links" => { "next" => next_url }
                          }.to_json,
                          headers: { 'Content-Type' => 'application/json' }
                        )
        next_request = stub_request(:get, next_url).
                       to_return(
                         status: 200,
                         body: {
                           "data" => [{
                             "type" => "reviewSubmissionItems",
                             "id" => "app-version-item",
                             "relationships" => {
                               "appStoreVersion" => {
                                 "data" => { "type" => "appStoreVersions", "id" => "app-version" }
                               }
                             }
                           }]
                         }.to_json,
                         headers: { 'Content-Type' => 'application/json' }
                       )

        expect(review_submission.items_only?).to eq(false)
        expect(first_request).to have_been_requested.once
        expect(next_request).to have_been_requested.once
      end

      it 'returns true when every item explicitly has no app store version' do
        item = {
          "type" => "reviewSubmissionItems",
          "id" => "page-item",
          "relationships" => {
            "appStoreVersion" => { "data" => nil },
            "appCustomProductPageVersion" => {
              "data" => { "type" => "appCustomProductPageVersions", "id" => "page-version" }
            }
          }
        }
        response = double('paginated_response')

        expect(client).to receive(:get_review_submission_items).with(review_submission_id: "123456789", includes: "appStoreVersion,appCustomProductPageVersion").and_return(response)
        expect(response).to receive(:all_pages).and_return([response_with_items([item])])

        expect(review_submission.items_only?(client: client)).to eq(true)
      end

      it 'returns false when an item contains an app store version on a later page' do
        page_item = {
          "relationships" => {
            "appStoreVersion" => { "data" => nil }
          }
        }
        app_version_item = {
          "relationships" => {
            "appStoreVersion" => {
              "data" => { "type" => "appStoreVersions", "id" => "app-version" }
            }
          }
        }
        response = double('paginated_response')
        pages = [
          response_with_items([page_item]),
          response_with_items([app_version_item])
        ]

        expect(client).to receive(:get_review_submission_items).with(review_submission_id: "123456789", includes: "appStoreVersion,appCustomProductPageVersion").and_return(response)
        expect(response).to receive(:all_pages).and_return(pages)

        expect(review_submission.items_only?(client: client)).to eq(false)
      end

      it 'returns false when an item omits its app store version relationship' do
        ambiguous_item = {
          "relationships" => {
            "appCustomProductPageVersion" => {
              "data" => { "type" => "appCustomProductPageVersions", "id" => "page-version" }
            }
          }
        }
        response = double('paginated_response')

        expect(client).to receive(:get_review_submission_items).with(review_submission_id: "123456789", includes: "appStoreVersion,appCustomProductPageVersion").and_return(response)
        expect(response).to receive(:all_pages).and_return([response_with_items([ambiguous_item])])

        expect(review_submission.items_only?(client: client)).to eq(false)
      end

      it 'returns false when the app store version relationship omits data' do
        ambiguous_item = {
          "relationships" => {
            "appStoreVersion" => {
              "links" => { "related" => "https://example.test/app-store-version" }
            }
          }
        }
        response = double('paginated_response')

        expect(client).to receive(:get_review_submission_items).with(review_submission_id: "123456789", includes: "appStoreVersion,appCustomProductPageVersion").and_return(response)
        expect(response).to receive(:all_pages).and_return([response_with_items([ambiguous_item])])

        expect(review_submission.items_only?(client: client)).to eq(false)
      end

      it 'returns false when the response body is malformed' do
        response = double('paginated_response')
        malformed_page = double('response', body: nil)

        expect(client).to receive(:get_review_submission_items).with(review_submission_id: "123456789", includes: "appStoreVersion,appCustomProductPageVersion").and_return(response)
        expect(response).to receive(:all_pages).and_return([malformed_page])

        expect(review_submission.items_only?(client: client)).to eq(false)
      end

      it 'returns false when the submission has no items' do
        response = double('paginated_response')

        expect(client).to receive(:get_review_submission_items).with(review_submission_id: "123456789", includes: "appStoreVersion,appCustomProductPageVersion").and_return(response)
        expect(response).to receive(:all_pages).and_return([response_with_items([])])

        expect(review_submission.items_only?(client: client)).to eq(false)
      end
    end
  end
end
