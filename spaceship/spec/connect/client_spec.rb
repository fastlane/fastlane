describe Spaceship::ConnectAPI::Client do
  let(:client) { Spaceship::ConnectAPI::Base.client }
  let(:hostname) { Spaceship::ConnectAPI::Client.hostname }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  before do
    Spaceship::Tunes.login(username, password)
  end

  context 'build_params' do
    let(:path) { "betaAppReviewDetails" }
    let(:one_filter) { { build: "123" } }
    let(:two_filters) { { build: "123", app: "321" } }
    let(:includes) { "model.attribute" }
    let(:limit) { "30" }
    let(:sort) { "asc" }

    it 'builds params with nothing' do
      url = client.build_params
      # expect(url).to eq(path)
    end

    it 'builds params with one filter' do
      url = client.build_params(filter: one_filter)
      # expect(url).to eq("#{path}?filter[build]=#{one_filter[:build]}")
    end

    it 'builds params with two filters' do
      url = client.build_params(filter: two_filters)
      # expect(url).to eq("#{path}?filter[build]=#{two_filters[:build]}&filter[app]=#{two_filters[:app]}")
    end

    it 'builds params with includes' do
      url = client.build_params(includes: includes)
      # expect(url).to eq("#{path}?include=#{includes}")
    end

    it 'builds params with limit' do
      url = client.build_params(limit: limit)
      # expect(url).to eq("#{path}?limit=#{limit}")
    end

    it 'builds params with sort' do
      url = client.build_params(sort: sort)
      # expect(url).to eq("#{path}?sort=#{sort}")
    end

    it 'builds params with one filter, includes, limit, and sort' do
      url = client.build_params(filter: one_filter, includes: includes, limit: limit, sort: sort)
      # expect(url).to eq("#{path}?filter[build]=#{one_filter[:build]}&include=#{includes}&limit=#{limit}&sort=#{sort}")
    end
  end

  context 'sends api request' do
    before(:each) do
      allow(client).to receive(:handle_response)
    end

    def test_request_params(url, params)
      req_mock = double
      options_mock = double
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

    context 'get_beta_app_review_detail' do
      let(:path) { "betaAppReviewDetails" }
      let(:app_id) { "123" }

      it 'succeeds' do
        params = {}
        req_mock = test_request_params(path, params)
        expect(client).to receive(:request).with(:get, path).and_yield(req_mock)
        client.get_beta_app_review_detail
      end

      it 'succeeds with filter' do
        params = { filter: { app: app_id } }
        req_mock = test_request_params(path, params)
        expect(client).to receive(:request).with(:get, path).and_yield(req_mock)
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
      let(:path) { "betaAppLocalizations" }
      let(:app_id) { "123" }

      it 'succeeds' do
        params = {}
        req_mock = test_request_params(path, params)
        expect(client).to receive(:request).with(:get, path).and_yield(req_mock)
        client.get_beta_app_localizations
      end

      it 'succeeds with filter' do
        params = { filter: { app: app_id } }
        req_mock = test_request_params(path, params)
        expect(client).to receive(:request).with(:get, path).and_yield(req_mock)
        client.get_beta_app_localizations(params)
      end
    end

    context 'get_beta_build_localizations' do
      let(:path) { "betaBuildLocalizations" }
      let(:build_id) { "123" }

      it 'succeeds' do
        params = {}
        req_mock = test_request_params(path, params)
        expect(client).to receive(:request).with(:get, path).and_yield(req_mock)
        client.get_beta_build_localizations
      end

      it 'succeeds with filter' do
        params = { filter: { build: build_id } }
        req_mock = test_request_params(path, params)
        expect(client).to receive(:request).with(:get, path).and_yield(req_mock)
        client.get_beta_build_localizations(params)
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
      let(:path) { "buildBetaDetails" }
      let(:build_id) { "123" }

      it 'succeeds' do
        params = {}
        req_mock = test_request_params(path, params)
        expect(client).to receive(:request).with(:get, path).and_yield(req_mock)
        client.get_build_beta_details
      end

      it 'succeeds with filter' do
        params = { filter: { build: build_id } }
        req_mock = test_request_params(path, params)
        expect(client).to receive(:request).with(:get, path).and_yield(req_mock)
        client.get_build_beta_details(params)
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

    context 'get_build_deliveries' do
      let(:path) { "buildDeliveries" }
      let(:version) { "189" }
      let(:default_params) { { limit: 10 } }

      it 'succeeds' do
        params = {}
        req_mock = test_request_params(path, params.merge(default_params))
        expect(client).to receive(:request).with(:get, path).and_yield(req_mock)
        client.get_build_deliveries
      end

      it 'succeeds with filter' do
        params = { filter: { version: version } }
        req_mock = test_request_params(path, params.merge(default_params))
        expect(client).to receive(:request).with(:get, path).and_yield(req_mock)
        client.get_build_deliveries(params)
      end
    end

    context 'get_builds' do
      let(:path) { "builds" }
      let(:build_id) { "123" }
      let(:default_params) { { include: "buildBetaDetail,betaBuildMetrics", limit: 10, sort: "uploadedDate" } }

      it 'succeeds' do
        params = {}
        req_mock = test_request_params(path, params.merge(default_params))
        expect(client).to receive(:request).with(:get, path).and_yield(req_mock)
        client.get_builds
      end

      it 'succeeds with filter' do
        params = { filter: { expired: false, processingState: "PROCESSING,VALID", version: "123" } }
        req_mock = test_request_params(path, params.merge(default_params))
        expect(client).to receive(:request).with(:get, path).and_yield(req_mock)
        client.get_builds(params)
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
        client.patch_builds(build_id: build_id, attributes: attributes)
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

    context 'get_pre_release_versions' do
      let(:path) { "preReleaseVersions" }
      let(:version) { "189" }
      let(:default_params) { { limit: 40 } }

      it 'succeeds' do
        params = {}
        req_mock = test_request_params(path, params.merge(default_params))
        expect(client).to receive(:request).with(:get, path).and_yield(req_mock)
        client.get_pre_release_versions
      end

      it 'succeeds with filter' do
        params = { filter: { version: version } }
        req_mock = test_request_params(path, params.merge(default_params))
        expect(client).to receive(:request).with(:get, path).and_yield(req_mock)
        client.get_pre_release_versions(params)
      end
    end

    context 'get_beta_groups' do
      let(:path) { "betaGroups" }
      let(:name) { "sir group a lot" }
      let(:default_params) { { limit: 40 } }

      it 'succeeds' do
        params = {}
        req_mock = test_request_params(path, params.merge(default_params))
        expect(client).to receive(:request).with(:get, path).and_yield(req_mock)
        client.get_beta_groups
      end

      it 'succeeds with filter' do
        params = { filter: { name: name } }
        req_mock = test_request_params(path, params.merge(default_params))
        expect(client).to receive(:request).with(:get, path).and_yield(req_mock)
        client.get_beta_groups(params)
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
        client.add_beta_groups_to_build(build_id: build_id, beta_group_ids: beta_group_ids)
      end
    end
  end
end
