require 'deliver/upload_price_tier'
require 'deliver/options'

describe Deliver::UploadPriceTier do
  let(:uploader) { described_class.new }
  let(:app) { Spaceship::ConnectAPI::App.new('app-id', {}) }
  let(:usa) { Spaceship::ConnectAPI::Territory.new('USA', {}) }
  let(:canada) { Spaceship::ConnectAPI::Territory.new('CAN', {}) }
  let(:free) { Spaceship::ConnectAPI::AppPricePoint.new('free-point', customer_price: '0.00') }
  let(:paid) { Spaceship::ConnectAPI::AppPricePoint.new('paid-point', customer_price: '4.99') }
  let(:schedule) { Spaceship::ConnectAPI::AppPriceSchedule.new('schedule-id', base_territory: usa) }
  let(:prices) { [] }

  def price(id, point, start_date: nil, end_date: nil, territory: usa)
    Spaceship::ConnectAPI::AppPrice.new(id, app_price_point: point, territory: territory, start_date: start_date, end_date: end_date)
  end

  def expect_schedule(manual_prices, territory: 'USA')
    expect(Spaceship::ConnectAPI::AppPriceSchedule).to receive(:create).with(
      app_id: 'app-id', base_territory_id: territory, manual_prices: manual_prices
    )
  end

  before do
    allow(Time).to receive(:now).and_return(Time.utc(2026, 1, 10, 12))
    allow(Deliver).to receive(:cache).and_return(app: app)
    allow(app).to receive(:fetch_app_price_schedule).and_return(schedule)
    allow(schedule).to receive(:get_manual_prices).and_return(prices)
    allow(app).to receive(:get_app_price_points).with(filter: { territory: 'USA' }).and_return([paid, free])
    # Pricing must never change availability, even for initial pricing.
    expect(app).not_to receive(:update)
    expect(app).not_to receive(:prices)
    expect(Spaceship::ConnectAPI).not_to receive(:get_app_price)
    expect(Spaceship::ConnectAPI::Territory).not_to receive(:all)
  end

  it 'does nothing without a price option' do
    expect(app).not_to receive(:fetch_app_price_schedule)
    expect(Spaceship::ConnectAPI::AppPriceSchedule).not_to receive(:create)
    uploader.upload({})
  end

  context 'with resolved pricing options' do
    around do |example|
      FastlaneSpec::Env.with_env_values(
        'DELIVER_PRICE_TIER' => nil,
        'DELIVER_PRICE_POINT_ID' => nil,
        'DELIVER_PRICE_BASE_TERRITORY' => nil,
        'DELIVER_PRICE_START_DATE' => nil,
        'DELIVER_PRICE_END_DATE' => nil
      ) { example.run }
    end

    it 'does nothing when neither pricing option is configured' do
      config = FastlaneCore::Configuration.create(Deliver::Options.available_options, {})
      expect(app).not_to receive(:fetch_app_price_schedule)
      expect(Spaceship::ConnectAPI::AppPriceSchedule).not_to receive(:create)
      uploader.upload(config)
    end

    it 'accepts free pricing from the environment alone' do
      FastlaneSpec::Env.with_env_values('DELIVER_PRICE_TIER' => '0') do
        config = FastlaneCore::Configuration.create(Deliver::Options.available_options, {})
        expect_schedule([{ app_price_point_id: 'free-point', start_date: nil, end_date: nil }])
        uploader.upload(config)
      end
    end

    it 'accepts a paid price point from the configuration file alone' do
      config = FastlaneCore::Configuration.create(Deliver::Options.available_options, {})
      config.config_file_options = { price_point_id: 'paid-point' }
      expect_schedule([{ app_price_point_id: 'paid-point', start_date: nil, end_date: nil }])
      uploader.upload(config)
    end

    [:parameters, :environment, :configuration_file].repeated_permutation(2) do |tier_source, point_source|
      next if tier_source == :parameters && point_source == :parameters # ConfigItem already rejects direct conflicts.

      it "rejects free pricing from #{tier_source} with a paid price point from #{point_source} before contacting Apple" do
        sources = { parameters: {}, environment: {}, configuration_file: {} }
        sources[tier_source][:price_tier] = 0
        sources[point_source][:price_point_id] = 'paid-point'
        env = sources[:environment].to_h { |key, value| ["DELIVER_#{key.to_s.upcase}", value.to_s] }

        FastlaneSpec::Env.with_env_values(env) do
          config = FastlaneCore::Configuration.create(Deliver::Options.available_options, sources[:parameters])
          config.config_file_options = sources[:configuration_file]
          expect(app).not_to receive(:fetch_app_price_schedule)
          expect(Spaceship::ConnectAPI::AppPriceSchedule).not_to receive(:create)
          expect { uploader.upload(config) }.to raise_error(FastlaneCore::Interface::FastlaneError, /price_tier.*price_point_id/)
        end
      end
    end
  end

  it 'creates initial Free pricing through an app-specific zero price point' do
    allow(app).to receive(:fetch_app_price_schedule).and_return(nil)
    expect_schedule([{ app_price_point_id: 'free-point', start_date: nil, end_date: nil }])
    uploader.upload(price_tier: 0)
  end

  it 'initializes Free pricing when Apple returns a synthetic schedule and missing null resource' do
    schedule.id = app.id
    client = Spaceship::ConnectAPI::Tunes::Client.new(token: double('token', text: 'token', expired?: false, in_house: false))
    allow(schedule).to receive(:get_manual_prices).and_wrap_original { |method| method.call(client: client) }
    stub_request(:get, 'https://api.appstoreconnect.apple.com/v1/appPriceSchedules/app-id/manualPrices')
      .with(query: { 'include' => 'appPricePoint,territory', 'limit' => '200' })
      .to_return(status: 404, body: {
        errors: [{ status: '404', code: 'NOT_FOUND', title: 'The specified resource does not exist', detail: "There is no resource of type 'null' with id 'app-id'" }]
      }.to_json, headers: { 'Content-Type' => 'application/json' })
    expect_schedule([{ app_price_point_id: 'free-point', start_date: nil, end_date: nil }])
    uploader.upload(price_tier: 0)
  end

  it 'rejects initial future-only pricing without guessing the current price' do
    expect(Spaceship::ConnectAPI::AppPriceSchedule).not_to receive(:create)
    expect { uploader.upload(price_tier: 0, price_start_date: '2026-02-01') }.to raise_error(FastlaneCore::Interface::FastlaneError, /Initialize pricing/)
  end

  it 'rejects initial temporary pricing without a price to restore' do
    expect(Spaceship::ConnectAPI::AppPriceSchedule).not_to receive(:create)
    expect { uploader.upload(price_tier: 0, price_end_date: '2026-02-01') }.to raise_error(FastlaneCore::Interface::FastlaneError, /Initialize pricing/)
  end

  it 'sets an explicitly selected paid price point' do
    expect_schedule([{ app_price_point_id: 'paid-point', start_date: nil, end_date: nil }])
    uploader.upload(price_point_id: 'paid-point')
  end

  it 'preserves an existing non-US base territory' do
    schedule.base_territory = canada
    expect(app).to receive(:get_app_price_points).with(filter: { territory: 'CAN' }).and_return([paid])
    expect_schedule([{ app_price_point_id: 'paid-point', start_date: nil, end_date: nil }], territory: 'CAN')
    uploader.upload(price_point_id: 'paid-point')
  end

  it 'supports an explicit base territory on initial pricing' do
    allow(app).to receive(:fetch_app_price_schedule).and_return(nil)
    expect(app).to receive(:get_app_price_points).with(filter: { territory: 'CAN' }).and_return([free])
    expect_schedule([{ app_price_point_id: 'free-point', start_date: nil, end_date: nil }], territory: 'CAN')
    uploader.upload(price_tier: 0, price_base_territory: 'CAN')
  end

  it 'allows an initial base territory choice when Apple supplied an empty synthetic schedule' do
    expect(app).to receive(:get_app_price_points).with(filter: { territory: 'CAN' }).and_return([free])
    expect_schedule([{ app_price_point_id: 'free-point', start_date: nil, end_date: nil }], territory: 'CAN')
    uploader.upload(price_tier: 0, price_base_territory: 'CAN')
  end

  context 'with an existing current price' do
    let(:prices) { [price('current', free)] }

    it 'does not rewrite an unchanged price' do
      expect(Spaceship::ConnectAPI::AppPriceSchedule).not_to receive(:create)
      uploader.upload(price_tier: 0)
    end

    it 'changes the current price' do
      expect_schedule([{ app_price_point_id: 'paid-point', start_date: nil, end_date: nil }])
      uploader.upload(price_point_id: 'paid-point')
    end

    it 'restores the previous price after an immediate temporary change' do
      expect_schedule([
                        { app_price_point_id: 'free-point', start_date: '2026-02-01', end_date: nil },
                        { app_price_point_id: 'paid-point', start_date: nil, end_date: '2026-02-01' }
                      ])
      uploader.upload(price_point_id: 'paid-point', price_end_date: '2026-02-01')
    end

    ['2026-01-09', '2026-01-10', '2026-01-11'].each do |end_date|
      it "rejects an immediate change ending on #{end_date} before reading or changing pricing" do
        expect(app).not_to receive(:fetch_app_price_schedule)
        expect(Spaceship::ConnectAPI::AppPriceSchedule).not_to receive(:create)
        expect { uploader.upload(price_point_id: 'paid-point', price_end_date: end_date) }.to raise_error(FastlaneCore::Interface::FastlaneError, /price_end_date.*future/)
      end
    end

    it 'schedules a future change and retains the current price until then' do
      expect_schedule([
                        { app_price_point_id: 'free-point', start_date: nil, end_date: '2026-02-01' },
                        { app_price_point_id: 'paid-point', start_date: '2026-02-01', end_date: nil }
                      ])
      uploader.upload(price_point_id: 'paid-point', price_start_date: '2026-02-01')
    end

    it 'preserves an explicit same-day start and its preceding interval' do
      expect_schedule([
                        { app_price_point_id: 'free-point', start_date: nil, end_date: '2026-01-10' },
                        { app_price_point_id: 'paid-point', start_date: '2026-01-10', end_date: nil }
                      ])
      uploader.upload(price_point_id: 'paid-point', price_start_date: '2026-01-10')
    end

    it 'leaves explicit dates to Apple instead of rewriting dates based on the runner timezone' do
      expect_schedule([
                        { app_price_point_id: 'free-point', start_date: nil, end_date: '2026-01-09' },
                        { app_price_point_id: 'paid-point', start_date: '2026-01-09', end_date: nil }
                      ])
      uploader.upload(price_point_id: 'paid-point', price_start_date: '2026-01-09')
    end

    it 'captures one instant for all storefront comparison dates' do
      expect(Time).to receive(:now).once.and_return(Time.utc(2026, 1, 10, 12))
      expect(uploader.send(:comparison_dates)).to eq(['2026-01-10', '2026-01-10', '2026-01-11'])
    end

    it 'restores the previous price after a temporary change' do
      expect_schedule([
                        { app_price_point_id: 'free-point', start_date: nil, end_date: '2026-02-01' },
                        { app_price_point_id: 'free-point', start_date: '2026-03-01', end_date: nil },
                        { app_price_point_id: 'paid-point', start_date: '2026-02-01', end_date: '2026-03-01' }
                      ])
      uploader.upload(price_point_id: 'paid-point', price_start_date: '2026-02-01', price_end_date: '2026-03-01')
    end
  end

  context 'with existing scheduled and country-specific prices' do
    let(:prices) do
      [
        price('history', paid, end_date: '2026-01-01'),
        price('future', paid, start_date: '2026-03-01'),
        price('canada', paid, territory: canada),
        price('current', free, start_date: '2026-01-01', end_date: '2026-03-01')
      ]
    end

    it 'uses the active price rather than the first returned price for unchanged detection' do
      expect(Spaceship::ConnectAPI::AppPriceSchedule).not_to receive(:create)
      uploader.upload(price_tier: 0)
    end

    it 'preserves history, other country overrides, and future changes by ID' do
      expect_schedule([
                        { id: 'history' }, { id: 'future' }, { id: 'canada' },
                        { app_price_point_id: 'paid-point', start_date: nil, end_date: '2026-03-01' }
                      ])
      uploader.upload(price_point_id: 'paid-point')
    end

    it 'does not add a duplicate scheduled change' do
      expect(Spaceship::ConnectAPI::AppPriceSchedule).not_to receive(:create)
      uploader.upload(price_point_id: 'paid-point', price_start_date: '2026-03-01')
    end

    it 'inserts a future change without removing later scheduled changes' do
      expect_schedule([
                        { id: 'history' }, { id: 'future' }, { id: 'canada' },
                        { app_price_point_id: 'free-point', start_date: nil, end_date: '2026-02-01' },
                        { app_price_point_id: 'paid-point', start_date: '2026-02-01', end_date: '2026-03-01' }
                      ])
      uploader.upload(price_point_id: 'paid-point', price_start_date: '2026-02-01')
    end
  end

  context 'near a scheduled price boundary across timezones' do
    let(:prices) { [price('current', free, end_date: '2026-01-10'), price('upcoming', paid, start_date: '2026-01-10')] }

    before do
      # The runner can already be on January 10 while a storefront is on January 9.
      allow(Time).to receive(:now).and_return(Time.utc(2026, 1, 10, 1))
    end

    it 'does not mistake the upcoming target price for an unchanged current price' do
      expect(Spaceship::ConnectAPI::AppPriceSchedule).not_to receive(:create)
      expect { uploader.upload(price_point_id: 'paid-point') }.to raise_error(FastlaneCore::Interface::FastlaneError, /boundary may be taking effect/)
    end

    it 'does not discard a same-date future price when changing the current price' do
      expect(Spaceship::ConnectAPI::AppPriceSchedule).not_to receive(:create)
      expect { uploader.upload(price_tier: 0) }.to raise_error(FastlaneCore::Interface::FastlaneError, /price_start_date explicitly/)
    end

    it 'allows an explicit date without consulting the runner calendar' do
      expect(Spaceship::ConnectAPI::AppPriceSchedule).not_to receive(:create)
      uploader.upload(price_point_id: 'paid-point', price_start_date: '2026-01-10')
    end
  end

  it 'rejects an unknown or another app or territory price point' do
    expect(Spaceship::ConnectAPI::AppPriceSchedule).not_to receive(:create)
    expect { uploader.upload(price_point_id: 'other-app-point') }.to raise_error(FastlaneCore::Interface::FastlaneError, /No matching price point/)
  end

  it 'rejects a base territory change' do
    prices << price('current', free)
    expect { uploader.upload(price_tier: 0, price_base_territory: 'CAN') }.to raise_error(FastlaneCore::Interface::FastlaneError, /base territory is USA/)
  end

  it 'does not ignore a failure to read the existing schedule' do
    allow(app).to receive(:fetch_app_price_schedule).and_raise('Apple unavailable')
    expect(Spaceship::ConnectAPI::AppPriceSchedule).not_to receive(:create)
    expect { uploader.upload(price_tier: 0) }.to raise_error('Apple unavailable')
  end

  it 'does not overwrite a schedule with incomplete relationships' do
    prices << price('missing-territory', paid, territory: nil)
    expect(Spaceship::ConnectAPI::AppPriceSchedule).not_to receive(:create)
    expect { uploader.upload(price_tier: 0) }.to raise_error(FastlaneCore::Interface::FastlaneError, /Could not read all existing/)
  end

  it 'requires a price when dates are supplied' do
    expect { uploader.upload(price_start_date: '2026-02-01') }.to raise_error(FastlaneCore::Interface::FastlaneError, /require price_tier/)
  end

  it 'rejects an end date that is not after the start' do
    expect { uploader.upload(price_tier: 0, price_start_date: '2026-02-01', price_end_date: '2026-02-01') }.to raise_error(FastlaneCore::Interface::FastlaneError, /must be after/)
  end
end
