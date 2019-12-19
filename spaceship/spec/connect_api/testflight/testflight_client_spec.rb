describe Spaceship::ConnectAPI::TestFlight::Client do
  let(:client) { Spaceship::ConnectAPI::TestFlight::Client.instance }
  let(:hostname) { Spaceship::ConnectAPI::TestFlight::Client.hostname }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  before do
    Spaceship::Tunes.login(username, password)
  end

  context 'sends api request' do
    before(:each) do
      allow(client).to receive(:handle_response)
    end

    def test_request_params(url, params)
      req_mock = double
      options_mock = double

      allow(req_mock).to receive(:headers).and_return({})

      expect(req_mock).to receive(:url).with(url)
      expect(req_mock).to receive(:params=).with(params)
      expect(req_mock).to receive(:options).and_return(options_mock)
      expect(options_mock).to receive(:params_encoder=).with(Faraday::NestedParamsEncoder)

      return req_mock
    end

    def test_request_body(url, body)
      req_mock = double
      header_mock = double
      expect(req_mock).to receive(:url).with(url)
      expect(req_mock).to receive(:body=).with(JSON.generate(body))
      expect(req_mock).to receive(:headers).and_return(header_mock)
      expect(header_mock).to receive(:[]=).with("Content-Type", "application/json")

      return req_mock
    end

    describe "apps" do
      context 'get_apps' do
        let(:path) { "apps" }
        let(:bundle_id) { "com.bundle.id" }

        it 'succeeds' do
          params = {}
          req_mock = test_request_params(path, params)
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_apps
        end

        it 'succeeds with filter' do
          params = { filter: { bundleId: bundle_id } }
          req_mock = test_request_params(path, params)
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_apps(filter: { bundleId: bundle_id })
        end
      end

      context 'get_app' do
        let(:app_id) { "123456789" }
        let(:path) { "apps/#{app_id}" }

        it 'succeeds' do
          params = {}
          req_mock = test_request_params(path, params)
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_app(app_id: app_id)
        end
      end
    end

    describe "betaAppLocalizations" do
      context 'get_beta_app_localizations' do
        let(:path) { "betaAppLocalizations" }
        let(:app_id) { "123" }

        it 'succeeds' do
          params = {}
          req_mock = test_request_params(path, params)
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_beta_app_localizations
        end

        it 'succeeds with filter' do
          params = { filter: { app: app_id } }
          req_mock = test_request_params(path, params)
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_beta_app_localizations(params)
        end
      end

      context 'post_beta_app_localizations' do
        let(:path) { "betaAppLocalizations" }
        let(:app_id) { "123" }
        let(:attributes) { { key: "value" } }
        let(:body) do
          {
            data: {
              attributes: attributes,
              type: "betaAppLocalizations",
              relationships: {
                app: {
                  data: {
                    type: "apps",
                    id: app_id
                  }
                }
              }
            }
          }
        end

        it 'succeeds' do
          url = path
          req_mock = test_request_body(url, body)

          expect(client).to receive(:request).with(:post).and_yield(req_mock)
          Spaceship::ConnectAPI.post_beta_app_localizations(app_id: app_id, attributes: attributes)
        end
      end

      context 'patch_beta_app_localizations' do
        let(:path) { "betaAppLocalizations" }
        let(:localization_id) { "123" }
        let(:attributes) { { key: "value" } }
        let(:body) do
          {
            data: {
              attributes: attributes,
              id: localization_id,
              type: "betaAppLocalizations"
            }
          }
        end

        it 'succeeds' do
          url = "#{path}/#{localization_id}"
          req_mock = test_request_body(url, body)

          expect(client).to receive(:request).with(:patch).and_yield(req_mock)
          Spaceship::ConnectAPI.patch_beta_app_localizations(localization_id: localization_id, attributes: attributes)
        end
      end
    end

    describe "betaAppReviewDetails" do
      context 'get_beta_app_review_detail' do
        let(:path) { "betaAppReviewDetails" }
        let(:app_id) { "123" }

        it 'succeeds' do
          params = {}
          req_mock = test_request_params(path, params)
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_beta_app_review_detail
        end

        it 'succeeds with filter' do
          params = { filter: { app: app_id } }
          req_mock = test_request_params(path, params)
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_beta_app_review_detail(filter: { app: app_id })
        end
      end

      context 'patch_beta_app_review_detail' do
        let(:path) { "betaAppReviewDetails" }
        let(:app_id) { "123" }
        let(:attributes) { { key: "value" } }
        let(:body) do
          {
            data: {
              attributes: attributes,
              id: app_id,
              type: "betaAppReviewDetails"
            }
          }
        end

        it 'succeeds' do
          url = "#{path}/#{app_id}"
          req_mock = test_request_body(url, body)
          expect(client).to receive(:request).with(:patch).and_yield(req_mock)
          Spaceship::ConnectAPI.patch_beta_app_review_detail(app_id: app_id, attributes: attributes)
        end
      end
    end

    describe "betaAppReviewSubmissions" do
      context 'get_beta_app_review_submissions' do
        let(:path) { "betaAppReviewSubmissions" }
        let(:app_id) { "123" }

        it 'succeeds' do
          params = {}
          req_mock = test_request_params(path, params)
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_beta_app_review_submissions
        end

        it 'succeeds with filter' do
          params = { filter: { app: app_id } }
          req_mock = test_request_params(path, params)
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_beta_app_review_submissions(filter: { app: app_id })
        end
      end

      context 'post_beta_app_review_submissions' do
        let(:path) { "betaAppReviewSubmissions" }
        let(:build_id) { "123" }
        let(:body) do
          {
            data: {
              type: "betaAppReviewSubmissions",
              relationships: {
                build: {
                  data: {
                    type: "builds",
                    id: build_id
                  }
                }
              }
            }
          }
        end

        it 'succeeds' do
          url = path
          req_mock = test_request_body(url, body)

          expect(client).to receive(:request).with(:post).and_yield(req_mock)
          Spaceship::ConnectAPI.post_beta_app_review_submissions(build_id: build_id)
        end
      end

      context 'delete_beta_app_review_submission' do
        let(:beta_app_review_submission_id) { "123" }
        let(:path) { "betaAppReviewSubmissions/#{beta_app_review_submission_id}" }

        it 'succeeds' do
          params = {}
          req_mock = test_request_params(path, params)
          expect(client).to receive(:request).with(:delete).and_yield(req_mock)
          Spaceship::ConnectAPI.delete_beta_app_review_submission(beta_app_review_submission_id: beta_app_review_submission_id)
        end
      end
    end

    describe "betaBuildLocalizations" do
      context 'get_beta_build_localizations' do
        let(:path) { "betaBuildLocalizations" }
        let(:build_id) { "123" }

        it 'succeeds' do
          params = {}
          req_mock = test_request_params(path, params)
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_beta_build_localizations
        end

        it 'succeeds with filter' do
          params = { filter: { build: build_id } }
          req_mock = test_request_params(path, params)
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_beta_build_localizations(params)
        end
      end

      context 'post_beta_build_localizations' do
        let(:path) { "betaBuildLocalizations" }
        let(:build_id) { "123" }
        let(:attributes) { { key: "value" } }
        let(:body) do
          {
            data: {
              attributes: attributes,
              type: "betaBuildLocalizations",
              relationships: {
                build: {
                  data: {
                    type: "builds",
                    id: build_id
                  }
                }
              }
            }
          }
        end

        it 'succeeds' do
          url = path
          req_mock = test_request_body(url, body)

          expect(client).to receive(:request).with(:post).and_yield(req_mock)
          Spaceship::ConnectAPI.post_beta_build_localizations(build_id: build_id, attributes: attributes)
        end
      end

      context 'patch_beta_build_localizations' do
        let(:path) { "betaBuildLocalizations" }
        let(:localization_id) { "123" }
        let(:attributes) { { key: "value" } }
        let(:body) do
          {
            data: {
              attributes: attributes,
              id: localization_id,
              type: "betaBuildLocalizations"
            }
          }
        end

        it 'succeeds' do
          url = "#{path}/#{localization_id}"
          req_mock = test_request_body(url, body)

          expect(client).to receive(:request).with(:patch).and_yield(req_mock)
          Spaceship::ConnectAPI.patch_beta_build_localizations(localization_id: localization_id, attributes: attributes)
        end
      end
    end

    describe "betaFeedbacks" do
      context 'get_beta_feedbacks' do
        let(:path) { "betaFeedbacks" }
        let(:app_id) { "123456789" }
        let(:default_params) { {} }

        it 'succeeds' do
          params = {}
          req_mock = test_request_params(path, params.merge(default_params))
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_beta_feedback
        end

        it 'succeeds with filter' do
          params = { filter: { "build.app" => app_id } }
          req_mock = test_request_params(path, params.merge(default_params))
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_beta_feedback(params)
        end
      end
    end

    describe "betaGroups" do
      context 'get_beta_groups' do
        let(:path) { "betaGroups" }
        let(:name) { "sir group a lot" }
        let(:default_params) { {} }

        it 'succeeds' do
          params = {}
          req_mock = test_request_params(path, params.merge(default_params))
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_beta_groups
        end

        it 'succeeds with filter' do
          params = { filter: { name: name } }
          req_mock = test_request_params(path, params.merge(default_params))
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_beta_groups(params)
        end
      end

      context 'add_beta_groups_to_build' do
        let(:path) { "builds" }
        let(:build_id) { "123" }
        let(:beta_group_ids) { ["123", "456"] }
        let(:body) do
          {
            data: beta_group_ids.map do |id|
              {
                type: "betaGroups",
                id: id
              }
            end
          }
        end

        it 'succeeds' do
          url = "#{path}/#{build_id}/relationships/betaGroups"
          req_mock = test_request_body(url, body)

          expect(client).to receive(:request).with(:post).and_yield(req_mock)
          Spaceship::ConnectAPI.add_beta_groups_to_build(build_id: build_id, beta_group_ids: beta_group_ids)
        end
      end
    end

    describe "betaTesters" do
      context 'get_beta_testers' do
        let(:path) { "betaTesters" }
        let(:app_id) { "123" }

        it 'succeeds' do
          params = {}
          req_mock = test_request_params(path, params)
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_beta_testers
        end

        it 'succeeds with filter' do
          params = { filter: { app: app_id } }
          req_mock = test_request_params(path, params)
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_beta_testers(params)
        end
      end

      context 'post_bulk_beta_tester_assignments' do
        let(:path) { "bulkBetaTesterAssignments" }
        let(:beta_group_id) { "123" }
        let(:beta_testers) do
          [
            { email: "email1", firstName: "first1", lastName: "last1", errors: [] },
            { email: "email2", firstName: "first2", lastName: "last2", errors: [] }
          ]
        end
        let(:body) do
          {
            data: {
              attributes: {
                betaTesters: beta_testers
              },
              relationships: {
                betaGroup: {
                  data: {
                    type: "betaGroups",
                    id: beta_group_id
                  }
                }
              },
              type: "bulkBetaTesterAssignments"
            }
          }
        end

        it 'succeeds' do
          url = path
          req_mock = test_request_body(url, body)

          expect(client).to receive(:request).with(:post).and_yield(req_mock)
          Spaceship::ConnectAPI.post_bulk_beta_tester_assignments(beta_group_id: beta_group_id, beta_testers: beta_testers)
        end
      end

      context 'delete_beta_tester_from_apps' do
        let(:beta_tester_id) { "123" }
        let(:app_ids) { ["1234", "5678"] }
        let(:path) { "betaTesters/#{beta_tester_id}/relationships/apps" }
        let(:body) do
          {
            data: app_ids.map do |id|
              {
                type: "apps",
                id: id
              }
            end
          }
        end

        it 'succeeds' do
          url = path
          req_mock = test_request_body(url, body)

          expect(client).to receive(:request).with(:delete).and_yield(req_mock)
          Spaceship::ConnectAPI.delete_beta_tester_from_apps(beta_tester_id: beta_tester_id, app_ids: app_ids)
        end
      end

      context 'delete_beta_tester_from_beta_groups' do
        let(:beta_tester_id) { "123" }
        let(:beta_group_ids) { ["1234", "5678"] }
        let(:path) { "betaTesters/#{beta_tester_id}/relationships/betaGroups" }
        let(:body) do
          {
            data: beta_group_ids.map do |id|
              {
                type: "betaGroups",
                id: id
              }
            end
          }
        end

        it 'succeeds' do
          url = path
          req_mock = test_request_body(url, body)

          expect(client).to receive(:request).with(:delete).and_yield(req_mock)
          Spaceship::ConnectAPI.delete_beta_tester_from_beta_groups(beta_tester_id: beta_tester_id, beta_group_ids: beta_group_ids)
        end
      end
    end

    describe "builds" do
      context 'get_builds' do
        let(:path) { "builds" }
        let(:build_id) { "123" }
        let(:default_params) { { include: "buildBetaDetail,betaBuildMetrics", limit: 10, sort: "uploadedDate" } }

        it 'succeeds' do
          params = {}
          req_mock = test_request_params(path, params.merge(default_params))
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_builds
        end

        it 'succeeds with filter' do
          params = { filter: { expired: false, processingState: "PROCESSING,VALID", version: "123" } }
          req_mock = test_request_params(path, params.merge(default_params))
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_builds(params)
        end
      end

      context 'get_build' do
        let(:build_id) { "123" }
        let(:path) { "builds/#{build_id}" }

        it 'succeeds' do
          params = {}
          req_mock = test_request_params(path, params)
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_build(build_id: build_id)
        end
      end

      context 'patch_builds' do
        let(:path) { "builds" }
        let(:build_id) { "123" }
        let(:attributes) { { name: "some_name" } }
        let(:body) do
          {
            data: {
              attributes: attributes,
              id: build_id,
              type: "builds"
            }
          }
        end

        it 'succeeds' do
          url = "#{path}/#{build_id}"
          req_mock = test_request_body(url, body)

          expect(client).to receive(:request).with(:patch).and_yield(req_mock)
          Spaceship::ConnectAPI.patch_builds(build_id: build_id, attributes: attributes)
        end
      end
    end

    describe "buildBetaDetails" do
      context 'get_build_beta_details' do
        let(:path) { "buildBetaDetails" }
        let(:build_id) { "123" }

        it 'succeeds' do
          params = {}
          req_mock = test_request_params(path, params)
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_build_beta_details
        end

        it 'succeeds with filter' do
          params = { filter: { build: build_id } }
          req_mock = test_request_params(path, params)
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_build_beta_details(params)
        end
      end

      context 'patch_build_beta_details' do
        let(:path) { "buildBetaDetails" }
        let(:build_beta_details_id) { "123" }
        let(:attributes) { { key: "value" } }
        let(:body) do
          {
            data: {
              attributes: attributes,
              id: build_beta_details_id,
              type: "buildBetaDetails"
            }
          }
        end

        it 'succeeds' do
          url = "#{path}/#{build_beta_details_id}"
          req_mock = test_request_body(url, body)

          expect(client).to receive(:request).with(:patch).and_yield(req_mock)
          Spaceship::ConnectAPI.patch_build_beta_details(build_beta_details_id: build_beta_details_id, attributes: attributes)
        end
      end
    end

    describe "buildDeliveries" do
      context 'get_build_deliveries' do
        let(:path) { "buildDeliveries" }
        let(:version) { "189" }
        let(:default_params) { {} }

        it 'succeeds' do
          params = {}
          req_mock = test_request_params(path, params.merge(default_params))
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_build_deliveries
        end

        it 'succeeds with filter' do
          params = { filter: { version: version } }
          req_mock = test_request_params(path, params.merge(default_params))
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_build_deliveries(params)
        end
      end
    end

    describe "preReleaseVersions" do
      context 'get_pre_release_versions' do
        let(:path) { "preReleaseVersions" }
        let(:version) { "186" }
        let(:default_params) { {} }

        it 'succeeds' do
          params = {}
          req_mock = test_request_params(path, params.merge(default_params))
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_pre_release_versions
        end

        it 'succeeds with filter' do
          params = { filter: { version: version } }
          req_mock = test_request_params(path, params.merge(default_params))
          expect(client).to receive(:request).with(:get).and_yield(req_mock)
          Spaceship::ConnectAPI.get_pre_release_versions(params)
        end
      end
    end
  end
end
