describe 'Modern app pricing models' do
  let(:client) { double('client') }
  let(:app) { Spaceship::ConnectAPI::App.new('app-id', {}) }
  let(:schedule) { Spaceship::ConnectAPI::AppPriceSchedule.new('schedule-id', {}) }

  def paginated_response
    first = double('first page', to_models: ['first'])
    second = double('second page', to_models: ['second'])
    allow(first).to receive(:all_pages).and_return([first, second])
    first
  end

  it 'fetches every page of app-specific price points' do
    expect(client).to receive(:get_app_price_points).with(app_id: 'app-id', filter: { territory: 'USA' }, includes: 'territory', limit: 200, sort: nil).and_return(paginated_response)
    expect(app.get_app_price_points(client: client, filter: { territory: 'USA' })).to eq(['first', 'second'])
  end

  it 'fetches the price schedule including its base territory' do
    expect(client).to receive(:get_app_price_schedule).with(app_id: 'app-id', includes: 'baseTerritory').and_return(double(body: nil, to_models: [schedule]))
    expect(app.fetch_app_price_schedule(client: client)).to eq(schedule)
  end

  it 'returns nil when an app has no price schedule' do
    response = Spaceship::ConnectAPI::Response.new(body: { 'data' => nil })
    expect(client).to receive(:get_app_price_schedule).with(app_id: 'app-id', includes: 'baseTerritory').and_return(response)
    expect(app.fetch_app_price_schedule(client: client)).to be_nil
  end

  it 'does not treat a malformed schedule response as an unconfigured app' do
    response = Spaceship::ConnectAPI::Response.new(body: {})
    expect(client).to receive(:get_app_price_schedule).with(app_id: 'app-id', includes: 'baseTerritory').and_return(response)
    expect { app.fetch_app_price_schedule(client: client) }.to raise_error('No data')
  end

  it 'fetches every page of manual prices with price points and territories' do
    expect(client).to receive(:get_app_price_schedule_manual_prices).with(app_price_schedule_id: 'schedule-id', filter: {}, includes: 'appPricePoint,territory', limit: 200).and_return(paginated_response)
    expect(schedule.get_manual_prices(client: client)).to eq(['first', 'second'])
  end

  it 'creates and returns a price schedule' do
    prices = [{ app_price_point_id: 'free-point', start_date: nil, end_date: nil }]
    expect(client).to receive(:post_app_price_schedule).with(app_id: 'app-id', base_territory_id: 'USA', manual_prices: prices).and_return(double(to_models: [schedule]))
    expect(Spaceship::ConnectAPI::AppPriceSchedule.create(client: client, app_id: app.id, base_territory_id: 'USA', manual_prices: prices)).to eq(schedule)
  end

  it 'parses modern schedule, price and price point relationships' do
    response = Spaceship::ConnectAPI::Response.new(body: {
      'data' => {
        'type' => 'appPriceSchedules', 'id' => 'schedule-id',
        'relationships' => {
          'baseTerritory' => { 'data' => { 'type' => 'territories', 'id' => 'USA' } },
          'manualPrices' => { 'data' => [{ 'type' => 'appPrices', 'id' => 'price' }] }
        }
      },
      'included' => [
        { 'type' => 'territories', 'id' => 'USA', 'attributes' => { 'currency' => 'USD' } },
        {
          'type' => 'appPrices', 'id' => 'price',
          'attributes' => { 'startDate' => '2026-01-01', 'endDate' => '2026-12-31', 'manual' => true },
          'relationships' => {
            'appPricePoint' => { 'data' => { 'type' => 'appPricePoints', 'id' => 'point' } },
            'territory' => { 'data' => { 'type' => 'territories', 'id' => 'USA' } }
          }
        },
        {
          'type' => 'appPricePoints', 'id' => 'point', 'attributes' => { 'customerPrice' => '0.0', 'proceeds' => '0.0' }
        }
      ]
    })
    model = response.to_models.first
    expect(model).to be_a(Spaceship::ConnectAPI::AppPriceSchedule)
    expect(model.base_territory.currency).to eq('USD')
    price = model.manual_prices.first
    expect(price.start_date).to eq('2026-01-01')
    expect(price.end_date).to eq('2026-12-31')
    expect(price.manual).to be(true)
    expect(price.territory.id).to eq('USA')
    expect(price.app_price_point.customer_price).to eq('0.0')
  end

  it 'retains the legacy price tier mapping' do
    price = Spaceship::ConnectAPI::AppPrice.new('legacy-price', 'priceTier' => 'tier')
    point = Spaceship::ConnectAPI::AppPricePoint.new('legacy-point', 'priceTier' => 'tier')
    expect(price.price_tier).to eq('tier')
    expect(point.price_tier).to eq('tier')
  end
end
