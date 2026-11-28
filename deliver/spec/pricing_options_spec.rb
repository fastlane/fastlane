require 'deliver/options'

describe 'deliver pricing options' do
  let(:options) { Deliver::Options.available_options }

  around do |example|
    FastlaneSpec::Env.with_env_values(
      'DELIVER_PRICE_TIER' => nil,
      'DELIVER_PRICE_POINT_ID' => nil,
      'DELIVER_PRICE_BASE_TERRITORY' => nil,
      'DELIVER_PRICE' => nil
    ) { example.run }
  end

  it 'accepts free pricing' do
    expect(FastlaneCore::Configuration.create(options, price_tier: 0)[:price_tier]).to eq(0)
  end

  it 'accepts a quoted customer price' do
    expect(FastlaneCore::Configuration.create(options, price: '0.99')[:price]).to eq('0.99')
  end

  it 'rejects nonzero legacy tiers at configuration time' do
    expect { FastlaneCore::Configuration.create(options, price_tier: 1) }.to raise_error(FastlaneCore::Interface::FastlaneError, /price_point_id/)
  end

  it 'rejects conflicting price options' do
    expect { FastlaneCore::Configuration.create(options, price_tier: 0, price_point_id: 'opaque-point') }.to raise_error(FastlaneCore::Interface::FastlaneError, /conflicting|Unresolved conflict/)
  end

  [0.99, 'USD 0.99', '-1', '1e2', '', '0,99'].each do |invalid_price|
    it "rejects invalid price #{invalid_price.inspect}" do
      expect { FastlaneCore::Configuration.create(options, price: invalid_price) }.to raise_error(FastlaneCore::Interface::FastlaneError, /price/)
    end
  end

  it 'rejects blank price point IDs' do
    expect { FastlaneCore::Configuration.create(options, price_point_id: '  ') }.to raise_error(FastlaneCore::Interface::FastlaneError, /must not be empty/)
  end

  it 'rejects malformed base territory IDs' do
    expect { FastlaneCore::Configuration.create(options, price_tier: 0, price_base_territory: 'US') }.to raise_error(FastlaneCore::Interface::FastlaneError, /three-letter/)
  end
end
