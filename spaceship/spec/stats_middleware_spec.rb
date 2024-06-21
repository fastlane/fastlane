describe Spaceship::StatsMiddleware do
  context '#log' do
    let(:app) { double('app') }
    let(:middleware) { Spaceship::StatsMiddleware.new(app) }

    before(:each) do
      allow(Spaceship::Globals).to receive(:verbose?).and_return(true)
    end

    it 'with nil env' do
      success = middleware.log(nil)

      expect(success).to be(false)
    end

    it 'with empty env' do
      mock_env = double('env')
      expect(mock_env).to receive(:url).and_return(nil)
      success = middleware.log(mock_env)

      expect(success).to be(false)
    end

    it 'with bad env url' do
      mock_env = double('env')
      expect(mock_env).to receive(:url).and_return("pizza is good").twice

      expect do
        success = middleware.log(mock_env)
        expect(success).to be(false)
      end.to output(/Failed to log spaceship stats/).to_stdout
    end

    it 'with api.appstoreconnect.apple.com' do
      mock_stats = Hash.new(0)
      allow(Spaceship::StatsMiddleware).to receive(:service_stats) do
        mock_stats
      end

      urls = [
        # Supported
        "https://api.appstoreconnect.apple.com/stuff",
        "https://api.appstoreconnect.apple.com/stuff2",
        "https://appstoreconnect.apple.com/iris/v1/stuff",
        "https://developer.apple.com/services-account/v1/stuff",
        "https://idmsa.apple.com/stuff",
        "https://appstoreconnect.apple.com/olympus/v1/stuff",
        "https://appstoreconnect.apple.com/WebObjects/iTunesConnect.woa/stuff",
        "https://developer.apple.com/services-account/QH65B2/stuff",

        # Custom
        "https://somethingelse.com/stuff",
        "https://somethingelse.com/stuff2"
      ]

      urls.each do |url|
        mock_env = double('env')
        allow(mock_env).to receive(:url).and_return(url)

        success = middleware.log(mock_env)
        expect(success).to be(true)
      end

      expect(Spaceship::StatsMiddleware.service_stats.size).to eq(8)

      expect(find_count("api.appstoreconnect.apple.com")).to eq(2)
      expect(find_count("appstoreconnect.apple.com/iris/")).to eq(1)
      expect(find_count("developer.apple.com/services-account/")).to eq(1)
      expect(find_count("idmsa.apple.com")).to eq(1)
      expect(find_count("appstoreconnect.apple.com/olympus/v1/")).to eq(1)
      expect(find_count("appstoreconnect.apple.com/WebObjects/iTunesConnect.woa/")).to eq(1)
      expect(find_count("developer.apple.com/services-account/QH65B2/")).to eq(1)
      expect(find_count("somethingelse.com")).to eq(2)
    end

    def find_count(url)
      Spaceship::StatsMiddleware.service_stats.find { |k, v| k.url == url }.last
    end
  end
end
