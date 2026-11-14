describe 'Modern app pricing requests' do
  let(:client) { Spaceship::ConnectAPI::Tunes::Client.new(token: double('token', text: 'token', expired?: false, in_house: false)) }
  let(:hostname) { 'https://api.appstoreconnect.apple.com/' }

  def stub_pricing_get(path, params = {})
    stub_request(:get, "#{hostname}#{path}").with(query: params).to_return(status: 200, body: { data: [] }.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  it 'keeps the legacy unscoped price point endpoint' do
    request = stub_pricing_get('v1/appPricePoints', 'filter[priceTier]' => '1')
    client.get_app_price_points(filter: { priceTier: '1' })
    expect(request).to have_been_requested
  end

  it 'uses the app-scoped price point endpoint when an app id is provided' do
    request = stub_pricing_get('v1/apps/app-id/appPricePoints', 'filter[territory]' => 'USA', 'include' => 'territory', 'limit' => '200')
    client.get_app_price_points(app_id: 'app-id', filter: { territory: 'USA' }, includes: 'territory', limit: 200)
    expect(request).to have_been_requested
  end

  it 'reads the app price schedule' do
    request = stub_pricing_get('v1/apps/app-id/appPriceSchedule', 'include' => 'baseTerritory')
    client.get_app_price_schedule(app_id: 'app-id', includes: 'baseTerritory')
    expect(request).to have_been_requested
  end

  it 'reads manual schedule prices' do
    request = stub_pricing_get('v1/appPriceSchedules/schedule-id/manualPrices', 'include' => 'appPricePoint,territory', 'limit' => '200')
    client.get_app_price_schedule_manual_prices(app_price_schedule_id: 'schedule-id', includes: 'appPricePoint,territory', limit: 200)
    expect(request).to have_been_requested
  end

  it 'creates Free pricing using an explicit price point with open dates' do
    body = {
      data: {
        type: 'appPriceSchedules',
        relationships: {
          app: { data: { type: 'apps', id: 'app-id' } },
          baseTerritory: { data: { type: 'territories', id: 'USA' } },
          manualPrices: { data: [{ type: 'appPrices', id: '${new-price-0}' }] }
        }
      },
      included: [{
        type: 'appPrices', id: '${new-price-0}', attributes: { startDate: nil, endDate: nil },
        relationships: { appPricePoint: { data: { type: 'appPricePoints', id: 'free-point' } } }
      }]
    }
    request = stub_request(:post, "#{hostname}v1/appPriceSchedules").with(body: body.to_json).to_return(status: 201, body: { data: { type: 'appPriceSchedules', id: 'schedule-id' } }.to_json, headers: { 'Content-Type' => 'application/json' })
    client.post_app_price_schedule(app_id: 'app-id', base_territory_id: 'USA', manual_prices: [{ app_price_point_id: 'free-point' }])
    expect(request).to have_been_requested
  end

  it 'references unchanged prices and includes only new scheduled prices' do
    request = stub_request(:post, "#{hostname}v1/appPriceSchedules").with do |req|
      body = JSON.parse(req.body)
      relationships = body.fetch('data').fetch('relationships')
      prices = relationships.fetch('manualPrices').fetch('data')
      included = body.fetch('included')
      prices == [{ 'type' => 'appPrices', 'id' => 'existing-price' }, { 'type' => 'appPrices', 'id' => '${new-price-1}' }] &&
        included == [{
          'type' => 'appPrices', 'id' => '${new-price-1}',
          'attributes' => { 'startDate' => '2027-01-01', 'endDate' => '2027-02-01' },
          'relationships' => { 'appPricePoint' => { 'data' => { 'type' => 'appPricePoints', 'id' => 'paid-point' } } }
        }]
    end.to_return(status: 201, body: { data: { type: 'appPriceSchedules', id: 'schedule-id' } }.to_json, headers: { 'Content-Type' => 'application/json' })
    client.post_app_price_schedule(app_id: 'app-id', base_territory_id: 'USA', manual_prices: [
                                     { id: 'existing-price' },
                                     { app_price_point_id: 'paid-point', start_date: '2027-01-01', end_date: '2027-02-01' }
                                   ])
    expect(request).to have_been_requested
  end
end

describe 'Unconfigured app pricing responses' do
  let(:client) { Spaceship::ConnectAPI::Tunes::Client.new(token: double('token', text: 'token', expired?: false, in_house: false)) }
  let(:schedule) { Spaceship::ConnectAPI::AppPriceSchedule.new('app-id', {}) }
  let(:url) { 'https://api.appstoreconnect.apple.com/v1/appPriceSchedules/app-id/manualPrices' }

  def stub_error(status, detail, code: 'NOT_FOUND')
    stub_request(:get, url).with(query: hash_including('include' => 'appPricePoint,territory', 'limit' => '200')).to_return(
      status: status, body: { errors: [{ status: status.to_s, code: code, title: 'The specified resource does not exist', detail: detail }] }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  it 'treats the specific missing null resource for this app as no manual prices' do
    stub_error(404, "There is no resource of type 'null' with id 'app-id'")
    expect(schedule.get_manual_prices(client: client)).to eq([])
  end

  ["There is no resource of type 'appPrices' with id 'app-id'", "There is no resource of type 'null' with id 'another-app'"].each do |detail|
    it "preserves other not-found errors: #{detail}" do
      stub_error(404, detail)
      expect { schedule.get_manual_prices(client: client) }.to raise_error(Spaceship::UnexpectedResponse)
    end
  end

  it 'does not hide authorization failures' do
    stub_error(403, "There is no resource of type 'null' with id 'app-id'", code: 'FORBIDDEN')
    expect { schedule.get_manual_prices(client: client) }.to raise_error(Spaceship::AccessForbiddenError)
  end

  it 'does not hide server failures' do
    stub_error(503, "There is no resource of type 'null' with id 'app-id'", code: 'SERVER_ERROR')
    expect { schedule.get_manual_prices(client: client) }.to raise_error(Spaceship::Client::InternalServerError)
  end

  it 'does not turn a later-page error into an empty schedule' do
    first = double('page')
    allow(client).to receive(:get_app_price_schedule_manual_prices).and_return(first)
    allow(first).to receive(:all_pages).and_raise(Spaceship::UnexpectedResponse, "The specified resource does not exist - There is no resource of type 'null' with id 'app-id'")
    expect { schedule.get_manual_prices(client: client) }.to raise_error(Spaceship::UnexpectedResponse)
  end

  it 'does not retry an ambiguous price schedule creation failure' do
    request = stub_request(:post, 'https://api.appstoreconnect.apple.com/v1/appPriceSchedules').to_return(status: 504, body: '{}', headers: { 'Content-Type' => 'application/json' })
    expect do
      client.post_app_price_schedule(app_id: 'app-id', base_territory_id: 'USA', manual_prices: [{ app_price_point_id: 'point' }])
    end.to raise_error(Spaceship::Client::InternalServerError)
    expect(request).to have_been_requested.once
  end

  it 'does not retry price schedule creation after a transport timeout' do
    request = stub_request(:post, 'https://api.appstoreconnect.apple.com/v1/appPriceSchedules').to_raise(Faraday::TimeoutError)
    expect do
      client.post_app_price_schedule(app_id: 'app-id', base_territory_id: 'USA', manual_prices: [{ app_price_point_id: 'point' }])
    end.to raise_error(Faraday::TimeoutError)
    expect(request).to have_been_requested.once
  end

  it 'does not retry price schedule creation after an HTML gateway failure' do
    request = stub_request(:post, 'https://api.appstoreconnect.apple.com/v1/appPriceSchedules').to_return(
      status: 502, body: '<html><h3>Bad Gateway</h3></html>', headers: { 'Content-Type' => 'text/html' }
    )
    expect do
      client.post_app_price_schedule(app_id: 'app-id', base_territory_id: 'USA', manual_prices: [{ app_price_point_id: 'point' }])
    end.to raise_error(Spaceship::BadGatewayError)
    expect(request).to have_been_requested.once
  end
end
