describe Fastlane::CrashlyticsBetaInfo do
  describe 'data validation' do
    let(:beta_info) { Fastlane::CrashlyticsBetaInfo.new }

    describe 'crashlytics_path' do
      it 'finds a nil crashlytics_path to be invalid' do
        expect(beta_info.crashlytics_path_valid?).to be(false)
      end

      it 'finds an existing crashlytics_path to be valid' do
        beta_info.crashlytics_path = 'spec/fixtures/xcodeproj/Crashlytics.framework'

        expect(beta_info.crashlytics_path_valid?).to be(true)
      end
    end

    describe 'api_key' do
      it 'finds a nil API key to be invalid' do
        expect(beta_info.api_key_valid?).to be(false)
      end

      it 'finds an API key of the wrong length to be invalid' do
        beta_info.api_key = 'abcd1234'

        expect(beta_info.api_key_valid?).to be(false)
      end

      it 'finds an API key of the right length to be valid' do
        beta_info.api_key = 'a' * 40

        expect(beta_info.api_key_valid?).to be(true)
      end
    end

    describe 'build_secret' do
      it 'finds a nil build secret to be invalid' do
        expect(beta_info.build_secret_valid?).to be(false)
      end

      it 'finds an build secret of the wrong length to be invalid' do
        beta_info.build_secret = 'abcd1234'

        expect(beta_info.build_secret_valid?).to be(false)
      end

      it 'finds a build secret of the right length to be valid' do
        beta_info.build_secret = 'a' * 64

        expect(beta_info.build_secret_valid?).to be(true)
      end
    end

    describe 'emails' do
      it 'finds a nil emails to be invalid' do
        expect(beta_info.emails_valid?).to be(false)
      end

      it 'finds an empty emails array to be invalid' do
        beta_info.emails = []

        expect(beta_info.emails_valid?).to be(false)
      end

      it 'finds an empty email string to be invalid' do
        beta_info.emails = ['']

        expect(beta_info.emails_valid?).to be(false)
      end

      it 'finds a nil email string to be invalid' do
        beta_info.emails = [nil]

        expect(beta_info.emails_valid?).to be(false)
      end

      it 'finds a list of valid emails to be valid' do
        beta_info.emails = ['email@domain.com', 'another_email@domain.com']

        expect(beta_info.emails_valid?).to be(true)
      end
    end
  end
end
