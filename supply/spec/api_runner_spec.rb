require 'supply/api_runner'
require 'tmpdir'

describe Supply::ApiRunner do
  let(:api) { "https://androidpublisher.googleapis.com/androidpublisher/v3/applications/com.example" }
  let(:json) { { 'Content-Type' => 'application/json' } }

  def run(**args)
    Supply::ApiRunner.new(json_key: fixture_file("sample-service-account.json"), **args).run
  end

  before do
    stub_request(:post, "https://www.googleapis.com/oauth2/v4/token")
      .to_return(status: 200, body: '{"access_token":"a-token","expires_in":3600}', headers: json)
  end

  it 'prints the response body of a GET with the service account token' do
    stub = stub_request(:get, "#{api}/edits/1/tracks")
           .with(headers: { 'Authorization' => 'Bearer a-token' })
           .to_return(status: 200, body: '{"tracks":[{"track":"internal"}]}', headers: json)

    output = run(method: 'get', path: '/androidpublisher/v3/applications/com.example/edits/1/tracks')

    expect(stub).to have_been_requested
    expect(JSON.parse(output)).to eq({ 'tracks' => [{ 'track' => 'internal' }] })
  end

  it 'merges pages that use pageToken and nextPageToken' do
    stub_request(:get, "#{api}/subscriptions").to_return(status: 200, body: '{"subscriptions":[{"productId":"a"}],"nextPageToken":"p2"}', headers: json)
    stub_request(:get, "#{api}/subscriptions?pageToken=p2").to_return(status: 200, body: '{"subscriptions":[{"productId":"b"}]}', headers: json)

    result = JSON.parse(run(method: 'GET', path: '/androidpublisher/v3/applications/com.example/subscriptions', paginate: true))

    expect(result).to eq({ 'subscriptions' => [{ 'productId' => 'a' }, { 'productId' => 'b' }] })
  end

  it 'merges pages that use token and tokenPagination' do
    stub_request(:get, "#{api}/reviews?maxResults=1").to_return(status: 200, body: '{"reviews":[{"reviewId":"1"}],"tokenPagination":{"nextPageToken":"t2"}}', headers: json)
    stub_request(:get, "#{api}/reviews?maxResults=1&token=t2").to_return(status: 200, body: '{"reviews":[{"reviewId":"2"}],"tokenPagination":{}}', headers: json)

    result = JSON.parse(run(method: 'GET', path: '/androidpublisher/v3/applications/com.example/reviews?maxResults=1', paginate: true))

    expect(result).to eq({ 'reviews' => [{ 'reviewId' => '1' }, { 'reviewId' => '2' }] })
  end

  it 'sends a JSON body read from @file' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'track.json')
      File.write(path, '{"track":"beta","releases":[]}')
      stub = stub_request(:put, "#{api}/edits/1/tracks/beta")
             .with(body: '{"track":"beta","releases":[]}', headers: { 'Content-Type' => 'application/json' })
             .to_return(status: 200, body: '{"track":"beta"}', headers: json)

      run(method: 'PUT', path: '/androidpublisher/v3/applications/com.example/edits/1/tracks/beta', body: "@#{path}")

      expect(stub).to have_been_requested
    end
  end

  it 'sends a POST without a body' do
    stub = stub_request(:post, "#{api}/edits").to_return(status: 200, body: '{"id":"1"}', headers: json)

    expect(JSON.parse(run(method: 'POST', path: '/androidpublisher/v3/applications/com.example/edits'))).to eq({ 'id' => '1' })
    expect(stub).to have_been_requested
  end

  it 'refuses a DELETE without --yes, and sends it with --yes' do
    stub = stub_request(:delete, "#{api}/edits/1").to_return(status: 204, body: '')

    expect { run(method: 'DELETE', path: '/androidpublisher/v3/applications/com.example/edits/1') }.to raise_error(FastlaneCore::Interface::FastlaneError, /--yes/)
    expect(stub).not_to have_been_requested

    expect(run(method: 'DELETE', path: '/androidpublisher/v3/applications/com.example/edits/1', yes: true)).to be_nil
    expect(stub).to have_been_requested
  end

  it "reports Google's error as a user error" do
    stub_request(:get, "#{api}/edits/9").to_return(status: 404, body: '{"error":{"code":404,"message":"No edit with id 9."}}', headers: json)

    expect { run(method: 'GET', path: '/androidpublisher/v3/applications/com.example/edits/9') }.to raise_error(FastlaneCore::Interface::FastlaneError, /No edit with id 9/)
  end

  it 'rejects invalid input before sending a request' do
    expect { run(method: 'HEAD', path: '/androidpublisher/v3/x') }.to raise_error(FastlaneCore::Interface::FastlaneError, /Unsupported method/)
    expect { run(method: 'GET', path: '/androidpublisher/v3/x', body: '{}') }.to raise_error(FastlaneCore::Interface::FastlaneError, /GET takes no --body/)
    expect { run(method: 'POST', path: '/androidpublisher/v3/x', paginate: true) }.to raise_error(FastlaneCore::Interface::FastlaneError, /--paginate only applies to GET/)
    expect { run(method: 'POST', path: '/androidpublisher/v3/x', body: '{') }.to raise_error(FastlaneCore::Interface::FastlaneError, /not valid JSON/)
    expect { run(method: 'GET', path: 'https://example.com/androidpublisher/v3/x') }.to raise_error(FastlaneCore::Interface::FastlaneError, /not a full URL/)
  end
end
