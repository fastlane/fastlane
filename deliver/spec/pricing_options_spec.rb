require 'deliver/options'

describe 'deliver pricing options' do
  let(:options) { Deliver::Options.available_options }

  around do |example|
    FastlaneSpec::Env.with_env_values(
      'DELIVER_PRICE_TIER' => nil,
      'DELIVER_PRICE_POINT_ID' => nil,
      'DELIVER_PRICE_BASE_TERRITORY' => nil,
      'DELIVER_PRICE_START_DATE' => nil,
      'DELIVER_PRICE_END_DATE' => nil
    ) { example.run }
  end

  it 'accepts free pricing' do
    expect(FastlaneCore::Configuration.create(options, price_tier: 0)[:price_tier]).to eq(0)
  end

  it 'accepts paid pricing with schedule dates' do
    config = FastlaneCore::Configuration.create(options, price_point_id: 'opaque-point', price_base_territory: 'USA', price_start_date: '2026-02-01', price_end_date: '2026-03-01')
    expect(config[:price_point_id]).to eq('opaque-point')
  end

  it 'rejects nonzero legacy tiers at configuration time' do
    expect { FastlaneCore::Configuration.create(options, price_tier: 1) }.to raise_error(FastlaneCore::Interface::FastlaneError, /price_point_id/)
  end

  it 'rejects conflicting price options' do
    expect { FastlaneCore::Configuration.create(options, price_tier: 0, price_point_id: 'opaque-point') }.to raise_error(FastlaneCore::Interface::FastlaneError, /conflicting|Unresolved conflict/)
  end

  ['2026-02-30', '2026-2-1', 'tomorrow'].each do |invalid_date|
    it "rejects invalid start date #{invalid_date} at configuration time" do
      expect { FastlaneCore::Configuration.create(options, price_tier: 0, price_start_date: invalid_date) }.to raise_error(FastlaneCore::Interface::FastlaneError, /YYYY-MM-DD/)
    end
  end

  it 'rejects blank price point IDs' do
    expect { FastlaneCore::Configuration.create(options, price_point_id: '  ') }.to raise_error(FastlaneCore::Interface::FastlaneError, /must not be empty/)
  end

  it 'rejects malformed base territory IDs' do
    expect { FastlaneCore::Configuration.create(options, price_tier: 0, price_base_territory: 'US') }.to raise_error(FastlaneCore::Interface::FastlaneError, /three-letter/)
  end
end
