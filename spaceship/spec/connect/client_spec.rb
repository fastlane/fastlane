describe Spaceship::ConnectAPI::Client do
  let(:client) { Spaceship::ConnectAPI::Base.client }
  let(:hostname) { Spaceship::ConnectAPI::Client.hostname }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  before do
    Spaceship::Tunes.login(username, password)
  end

  context 'build_url' do
    let(:path) { "betaAppReviewDetails" }
    let(:one_filter) { { build: "123" } }
    let(:two_filters) { { build: "123", app: "321" } }
    let(:includes) { "model.attribute" }
    let(:limit) { "30" }
    let(:sort) { "asc" }

    it 'builds url with only path' do
      url = client.build_url(path: path)
      expect(url).to eq(path)
    end

    it 'builds url with path and one filter' do
      url = client.build_url(path: path, filter: one_filter)
      expect(url).to eq("#{path}?filter[build]=#{one_filter[:build]}")
    end

    it 'builds url with path and two filters' do
      url = client.build_url(path: path, filter: two_filters)
      expect(url).to eq("#{path}?filter[build]=#{two_filters[:build]}&filter[app]=#{two_filters[:app]}")
    end

    it 'builds url with path and includes' do
      url = client.build_url(path: path, includes: includes)
      expect(url).to eq("#{path}?include=#{includes}")
    end

    it 'builds url with path and limit' do
      url = client.build_url(path: path, limit: limit)
      expect(url).to eq("#{path}?limit=#{limit}")
    end

    it 'builds url with path and sort' do
      url = client.build_url(path: path, sort: sort)
      expect(url).to eq("#{path}?sort=#{sort}")
    end

    it 'builds url with path, one filter, includes, limit, and sort' do
      url = client.build_url(path: path, filter: one_filter, includes: includes, limit: limit, sort: sort)
      expect(url).to eq("#{path}?filter[build]=#{one_filter[:build]}&include=#{includes}&limit=#{limit}&sort=#{sort}")
    end
  end

  context 'sends api request' do
    before(:each) do
      allow(client).to receive(:handle_response)
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

    context 'get_beta_app_review_detail' do
      let(:app_id) { "123" }

      it 'succeeds' do
        expect(client).to receive(:request).with(:get, "betaAppReviewDetails")
        client.get_beta_app_review_detail
      end

      it 'succeeds with filter' do
        expect(client).to receive(:request).with(:get, "betaAppReviewDetails?filter[app]=#{app_id}")
        client.get_beta_app_review_detail(filter: { app: app_id })
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
        client.patch_beta_app_review_detail(app_id: app_id, attributes: attributes)
      end
    end

    context 'get_beta_app_localizations' do
      let(:app_id) { "123" }

      it 'succeeds' do
        expect(client).to receive(:request).with(:get, "betaAppLocalizations")
        client.get_beta_app_localizations
      end

      it 'succeeds with filter' do
        app_id = "123"
        expect(client).to receive(:request).with(:get, "betaAppLocalizations?filter[app]=#{app_id}")
        client.get_beta_app_localizations(filter: { app: app_id })
      end
    end

    context 'get_beta_build_localizations' do
      let(:build_id) { "123" }

      it 'succeeds' do
        expect(client).to receive(:request).with(:get, "betaBuildLocalizations")
        client.get_beta_build_localizations
      end

      it 'succeeds with filter' do
        expect(client).to receive(:request).with(:get, "betaBuildLocalizations?filter[build]=#{build_id}")
        client.get_beta_build_localizations(filter: { build: build_id })
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
        client.post_beta_app_localizations(app_id: app_id, attributes: attributes)
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
        client.patch_beta_app_localizations(localization_id: localization_id, attributes: attributes)
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
        client.post_beta_build_localizations(build_id: build_id, attributes: attributes)
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
        client.patch_beta_build_localizations(localization_id: localization_id, attributes: attributes)
      end
    end

    context 'get_build_beta_details' do
      let(:build_id) { "123" }

      it 'succeeds' do
        expect(client).to receive(:request).with(:get, "buildBetaDetails")
        client.get_build_beta_details
      end

      it 'succeeds with filter' do
        expect(client).to receive(:request).with(:get, "buildBetaDetails?filter[build]=#{build_id}")
        client.get_build_beta_details(filter: { build: build_id })
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
        client.patch_build_beta_details(build_beta_details_id: build_beta_details_id, attributes: attributes)
      end
    end

    context 'get_builds' do
      let(:build_id) { "123" }
      let(:default_includes) { "buildBetaDetail,betaBuildMetrics&limit=10&sort=uploadedDate" }

      it 'succeeds' do
        expect(client).to receive(:request).with(:get, "builds?include=#{default_includes}")
        client.get_builds
      end

      it 'succeeds with filter' do
        expect(client).to receive(:request).with(:get, "builds?filter[expired]=false&filter[processingState]=PROCESSING,VALID&filter[version]=123&include=#{default_includes}")
        client.get_builds(filter: { expired: false, processingState: "PROCESSING,VALID", version: "123" })
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
        client.post_beta_app_review_submissions(build_id: build_id)
      end
    end

    #    def post_for_testflight_review(build_id: nil)
  end
end
