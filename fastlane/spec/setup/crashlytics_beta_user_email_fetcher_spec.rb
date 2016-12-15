describe Fastlane::CrashlyticsBetaUserEmailFetcher do
  describe 'Email fetching' do
    let(:valid_email) { 'appfile@krausefx.com' }

    it 'finds an email by apple_id' do
      fetcher = Fastlane::CrashlyticsBetaUserEmailFetcher.new('./fastlane/spec/fixtures/appfiles/Appfile_apple_id')
      expect(fetcher.fetch).to eq(valid_email)
    end

    it 'finds an email by itunes_connect_id' do
      fetcher = Fastlane::CrashlyticsBetaUserEmailFetcher.new('./fastlane/spec/fixtures/appfiles/Appfile_itunes_connect_id')
      expect(fetcher.fetch).to eq(valid_email)
    end

    it 'finds an email by apple_dev_portal_id' do
      fetcher = Fastlane::CrashlyticsBetaUserEmailFetcher.new('./fastlane/spec/fixtures/appfiles/Appfile_dev_portal_id')
      expect(fetcher.fetch).to eq(valid_email)
    end

    it 'does not find an email' do
      fetcher = Fastlane::CrashlyticsBetaUserEmailFetcher.new('./fastlane/spec/fixtures/appfiles/Appfile_empty')
      expect(fetcher.fetch).to be_nil
    end
  end
end
