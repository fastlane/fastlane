require 'tmpdir'

describe Spaceship::ApiRunner do
  let(:token) { double('token', text: 'a-token', in_house: nil, expired?: false) }
  let(:api) { "https://api.appstoreconnect.apple.com/v1" }

  def run(**args)
    Spaceship::ApiRunner.new(api_key_path: 'key.json', **args).run
  end

  before do
    allow(Spaceship::ConnectAPI::Token).to receive(:from).with(filepath: 'key.json').and_return(token)
  end

  it 'prints the response body of a GET with the key as bearer token' do
    stub = stub_request(:get, "#{api}/apps?limit=1")
           .with(headers: { 'Authorization' => 'Bearer a-token' })
           .to_return(status: 200, body: { data: [{ type: 'apps', id: '1' }] }.to_json, headers: { 'Content-Type' => 'application/json' })

    output = run(method: 'get', path: '/v1/apps?limit=1')

    expect(stub).to have_been_requested
    expect(JSON.parse(output)).to eq({ 'data' => [{ 'type' => 'apps', 'id' => '1' }] })
  end

  it 'merges every page with --paginate' do
    page1 = { data: [{ type: 'apps', id: '1' }], included: [{ type: 'builds', id: 'b' }], links: { next: "#{api}/apps?cursor=2" } }
    page2 = { data: [{ type: 'apps', id: '2' }], included: [{ type: 'builds', id: 'b' }], links: { self: "#{api}/apps?cursor=2" } }
    stub_request(:get, "#{api}/apps").to_return(status: 200, body: page1.to_json, headers: { 'Content-Type' => 'application/json' })
    stub_request(:get, "#{api}/apps?cursor=2").to_return(status: 200, body: page2.to_json, headers: { 'Content-Type' => 'application/json' })

    json = JSON.parse(run(method: 'GET', path: 'v1/apps', paginate: true))

    expect(json['data'].map { |app| app['id'] }).to eq(%w(1 2))
    expect(json['included']).to eq([{ 'type' => 'builds', 'id' => 'b' }])
    expect(json['links']).to eq({ 'self' => "#{api}/apps?cursor=2" })
  end

  it 'sends a body read from @file' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'body.json')
      File.write(path, '{"data":{"type":"betaGroups","id":"123","attributes":{"name":"QA"}}}')
      stub = stub_request(:patch, "#{api}/betaGroups/123")
             .with(body: { data: { type: 'betaGroups', id: '123', attributes: { name: 'QA' } } }.to_json)
             .to_return(status: 200, body: { data: { type: 'betaGroups', id: '123' } }.to_json, headers: { 'Content-Type' => 'application/json' })

      run(method: 'PATCH', path: '/v1/betaGroups/123', body: "@#{path}")

      expect(stub).to have_been_requested
    end
  end

  it 'refuses a DELETE without --yes and sends nothing' do
    stub = stub_request(:delete, "#{api}/betaGroups/123")

    expect { run(method: 'DELETE', path: '/v1/betaGroups/123') }.to raise_error(FastlaneCore::Interface::FastlaneError, /--yes/)
    expect(stub).not_to have_been_requested
  end

  it 'sends a DELETE with --yes and prints nothing for an empty response' do
    stub = stub_request(:delete, "#{api}/betaGroups/123").to_return(status: 204, body: '')

    expect(run(method: 'DELETE', path: '/v1/betaGroups/123', yes: true)).to be_nil
    expect(stub).to have_been_requested
  end

  it "reports Apple's error as a user error, without a stack trace" do
    errors = { errors: [{ status: '404', code: 'NOT_FOUND', title: 'The specified resource does not exist', detail: "There is no resource of type 'apps' with id '9'" }] }
    stub_request(:get, "#{api}/apps/9").to_return(status: 404, body: errors.to_json, headers: { 'Content-Type' => 'application/json' })

    expect { run(method: 'GET', path: '/v1/apps/9') }.to raise_error(FastlaneCore::Interface::FastlaneError, /There is no resource of type 'apps' with id '9'/)
  end

  it 'rejects invalid input before sending a request' do
    expect { run(method: 'PUT', path: '/v1/apps') }.to raise_error(FastlaneCore::Interface::FastlaneError, /Unsupported method/)
    expect { run(method: 'GET', path: '/v1/apps', body: '{}') }.to raise_error(FastlaneCore::Interface::FastlaneError, /GET takes no --body/)
    expect { run(method: 'POST', path: '/v1/apps', paginate: true) }.to raise_error(FastlaneCore::Interface::FastlaneError, /--paginate only applies to GET/)
    expect { run(method: 'POST', path: '/v1/apps', body: '{') }.to raise_error(FastlaneCore::Interface::FastlaneError, /not valid JSON/)
    expect { run(method: 'GET', path: 'https://example.com/v1/apps') }.to raise_error(FastlaneCore::Interface::FastlaneError, /not a full URL/)
  end

  it 'reuses a client set earlier, without logging in, when no key is given' do
    stub_const('ENV', ENV.to_h.reject { |key, _| key.start_with?('SPACESHIP_CONNECT_API') })
    existing = Spaceship::ConnectAPI::Client.new(token: token)
    allow(Spaceship::ConnectAPI).to receive(:client).and_return(existing)
    expect(Spaceship::ConnectAPI::Client).not_to receive(:login)
    stub_request(:get, "#{api}/apps").to_return(status: 200, body: { data: [] }.to_json, headers: { 'Content-Type' => 'application/json' })

    expect(Spaceship::ApiRunner.new(method: 'GET', path: '/v1/apps').request).to eq({ 'data' => [] })
  end

  it 'logs in with the Apple ID and uses the web session host when no key is set' do
    tunes_client = double('tunes_client', team_id: '123', csrf_tokens: nil, select_team: nil)
    allow(Spaceship::TunesClient).to receive(:login).with('user@example.com', nil).and_return(tunes_client)
    session_client = Spaceship::ConnectAPI::Client.new(tunes_client: tunes_client)
    expect(Spaceship::ConnectAPI::Client).to receive(:login).with('user@example.com', use_portal: false).and_return(session_client)
    expect(session_client.tunes_request_client).to receive(:request).and_return(double('response', status: 200, body: { 'data' => [] }, headers: {}))

    stub_const('ENV', ENV.to_h.reject { |key, _| key.start_with?('SPACESHIP_CONNECT_API') })
    allow(Spaceship::ConnectAPI).to receive(:client).and_return(nil)
    output = Spaceship::ApiRunner.new(method: 'GET', path: '/v1/apps', username: 'user@example.com').run

    expect(session_client.tunes_request_client.hostname).to eq('https://appstoreconnect.apple.com/iris/')
    expect(JSON.parse(output)).to eq({ 'data' => [] })
  end
end
