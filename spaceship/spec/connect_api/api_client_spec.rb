describe Spaceship::ConnectAPI::APIClient do
  describe "#build_params" do
    let(:mock_token) { double('token') }
    let(:client) { Spaceship::ConnectAPI::APIClient.new(token: mock_token) }

    before(:each) do
      allow(mock_token).to receive(:text).and_return("ewfawef")
    end

    context 'build_params' do
      let(:path) { "betaAppReviewDetails" }
      let(:nil_filter) { { build: nil } }
      let(:one_filter) { { build: "123" } }
      let(:two_filters) { { build: "123", app: "321" } }
      let(:includes) { "model.attribute" }
      let(:fields) { { a: 'aField', b: 'bField1,bField2' } }
      let(:limit) { "30" }
      let(:sort) { "asc" }

      it 'builds params with nothing' do
        params = client.build_params
        expect(params).to eq({})
      end

      it 'builds params with nil filter' do
        params = client.build_params(filter: nil_filter)
        expect(params).to eq({})
      end

      it 'builds params with one filter' do
        params = client.build_params(filter: one_filter)
        expect(params).to eq({
          filter: one_filter
        })
      end

      it 'builds params with two filters' do
        params = client.build_params(filter: two_filters)
        expect(params).to eq({
          filter: two_filters
        })
      end

      it 'builds params with includes' do
        params = client.build_params(includes: includes)
        expect(params).to eq({
          include: includes
        })
      end

      it 'builds params with fields' do
        params = client.build_params(fields: fields)
        expect(params).to eq({
          fields: fields
        })
      end

      it 'builds params with limit' do
        params = client.build_params(limit: limit)
        expect(params).to eq({
          limit: limit
        })
      end

      it 'builds params with sort' do
        params = client.build_params(sort: sort)
        expect(params).to eq({
          sort: sort
        })
      end

      it 'builds params with one filter, includes, fields, limit, and sort' do
        params = client.build_params(filter: one_filter, includes: includes, fields: fields, limit: limit, sort: sort)
        expect(params).to eq({
          filter: one_filter,
          include: includes,
          fields: fields,
          limit: limit,
          sort: sort
        })
      end
    end
  end

  describe "#request" do
    let(:mock_token) { double('token') }
    let(:client) { Spaceship::ConnectAPI::APIClient.new(token: mock_token) }

    let(:unauth_error) { Spaceship::Client::UnauthorizedAccessError.new }

    let(:default_body) { '{foo: "bar"}' }

    def stub_client_request(uri, status, body)
      stub_request(:get, uri).
        to_return(status: status, body: body, headers: { "Content-Type": "application/json" })
    end

    before(:each) do
      allow(mock_token).to receive(:text).and_return("ewfawef")
      allow(mock_token).to receive(:expired?).and_return(false)
    end

    it 'not raise on 200' do
      body = JSON.generate({ "data": { "hello": "world" } })
      stub_client_request(client.hostname, 200, body)

      client.get('')
    end

    it 'raise on 401' do
      body = JSON.generate({ "errors": [] })
      stub_client_request(client.hostname, 401, body)

      expect(mock_token).to receive(:refresh!).exactly(4).times

      expect do
        client.get('')
      end.to raise_error(Spaceship::UnauthorizedAccessError)
    end

    it 'raise on 403 with program license agreement updated' do
      body = JSON.generate({ "errors": [{ "code": "FORBIDDEN.REQUIRED_AGREEMENTS_MISSING_OR_EXPIRED" }] })
      stub_client_request(client.hostname, 403, body)

      expect do
        client.get('')
      end.to raise_error(Spaceship::ProgramLicenseAgreementUpdated)
    end

    it 'raise on 403' do
      body = JSON.generate({ "errors": [] })
      stub_client_request(client.hostname, 403, body)

      expect do
        client.get('')
      end.to raise_error(Spaceship::AccessForbiddenError)
    end

    describe 'with_retry' do
      it 'sleeps on 429' do
        stub_request(:get, client.hostname).
          to_return(status: 429).then.
          to_return(status: 200, body: "")

        expect(Kernel).to receive(:sleep).once.with(1)
        expect(client).to receive(:handle_response).once
        expect(client).to receive(:request).twice.and_call_original
        expect do
          client.get('')
        end.to_not(raise_error)
      end

      it 'sleeps until limit is reached on 429' do
        body = JSON.generate({ "errors": [{ "title": "The request rate limit has been reached.", "details": "We've received too many requests for this API. Please wait and try again or slow down your request rate." }] })
        stub_client_request(client.hostname, 429, body)

        expect(Kernel).to receive(:sleep).exactly(12).times
        expect do
          client.get('')
        end.to raise_error(Spaceship::ConnectAPI::APIClient::TooManyRequestsError, "Too many requests, giving up after backing off for > 3600 seconds.")
      end
    end
  end

  describe "#handle_error" do
    let(:mock_token) { double('token') }
    let(:client) { Spaceship::ConnectAPI::APIClient.new(token: mock_token) }
    let(:mock_response) { double('response') }

    describe "status of 200" do
      before(:each) do
        allow(mock_response).to receive(:status).and_return(200)
      end

      it 'does not raise' do
        allow(mock_response).to receive(:body).and_return({})

        expect do
          client.send(:handle_error, mock_response)
        end.to_not(raise_error)
      end
    end

    describe "status of 401" do
      before(:each) do
        allow(mock_response).to receive(:status).and_return(401)
      end

      it 'raises UnauthorizedAccessError with no errors in body' do
        allow(mock_response).to receive(:body).and_return({})

        expect do
          client.send(:handle_error, mock_response)
        end.to raise_error(Spaceship::UnauthorizedAccessError, /Unknown error/)
      end

      it 'raises UnauthorizedAccessError when body is string' do
        allow(mock_response).to receive(:body).and_return('{"errors":[{"title": "Some title", "detail": "some detail"}]}')

        expect do
          client.send(:handle_error, mock_response)
        end.to raise_error(Spaceship::UnauthorizedAccessError, /Some title - some detail/)
      end
    end

    describe "status of 403" do
      before(:each) do
        allow(mock_response).to receive(:status).and_return(403)
      end

      it 'raises ProgramLicenseAgreementUpdated with no errors in body FORBIDDEN.REQUIRED_AGREEMENTS_MISSING_OR_EXPIRED' do
        allow(mock_response).to receive(:body).and_return({
          "errors" => [
            {
              "code" => "FORBIDDEN.REQUIRED_AGREEMENTS_MISSING_OR_EXPIRED"
            }
          ]
        })

        expect do
          client.send(:handle_error, mock_response)
        end.to raise_error(Spaceship::ProgramLicenseAgreementUpdated)
      end

      it 'raises AccessForbiddenError with no errors in body' do
        allow(mock_response).to receive(:body).and_return({})

        expect do
          client.send(:handle_error, mock_response)
        end.to raise_error(Spaceship::AccessForbiddenError, /Unknown error/)
      end

      it 'raises AccessForbiddenError when body is string' do
        allow(mock_response).to receive(:body).and_return('{"errors":[{"title": "Some title", "detail": "some detail"}]}')

        expect do
          client.send(:handle_error, mock_response)
        end.to raise_error(Spaceship::AccessForbiddenError, /Some title - some detail/)
      end

      it 'raises AccessForbiddenError with errors in body' do
        allow(mock_response).to receive(:body).and_return({
          "errors" => [
            {
              "title" => "Some title",
              "detail" => "some detail"
            }
          ]
        })

        expect do
          client.send(:handle_error, mock_response)
        end.to raise_error(Spaceship::AccessForbiddenError, /Some title - some detail/)
      end
    end
  end
end
