describe Fastlane::CrashlyticsBetaInfo do
  let(:beta_info) { Fastlane::CrashlyticsBetaInfo.new }

  describe 'data validation' do
    describe 'crashlytics_path' do
      it 'finds a nil crashlytics_path to be invalid' do
        expect(beta_info.crashlytics_path_valid?).to be(false)
      end

      it 'finds an existing crashlytics_path to be valid' do
        beta_info.crashlytics_path = './fastlane/spec/fixtures/xcodeproj/Crashlytics.framework'

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

      it 'finds a list of valid emails to be valid' do
        beta_info.emails = ['email@domain.com', 'another_email@domain.com']

        expect(beta_info.emails_valid?).to be(true)
      end
    end

    describe 'schemes' do
      it 'finds a nil schemes to be invalid' do
        expect(beta_info.schemes_valid?).to be(false)
      end

      it 'finds an empty schemes to be invalid' do
        beta_info.schemes = ['']
        expect(beta_info.schemes_valid?).to be(false)
      end

      it 'finds a named schemes to be valid' do
        beta_info.schemes = ['whatever']
        expect(beta_info.schemes_valid?).to be(true)
      end
    end

    describe 'export_method' do
      it 'finds a nil export_method to be invalid' do
        expect(beta_info.export_method_valid?).to be(false)
      end

      it 'finds an empty export_method to be invalid' do
        beta_info.export_method = ''
        expect(beta_info.export_method_valid?).to be(false)
      end

      it 'finds an incorrect export_method to be invalid' do
        beta_info.export_method = 'rando'
        expect(beta_info.export_method_valid?).to be(false)
      end

      it 'finds a specific export_method to be valid' do
        beta_info.export_method = 'ad-hoc'
        expect(beta_info.export_method_valid?).to be(true)
      end
    end
  end

  describe 'assignment' do
    describe 'schemes' do
      it 'removes nil schemes from the array on assignment' do
        beta_info.schemes = [nil, 'whatever', nil]
        expect(beta_info.schemes).to eq(['whatever'])
      end
    end

    describe 'emails' do
      it 'removes nil emails from the array on assignment' do
        beta_info.emails = [nil, 'a@a.com', nil]
        expect(beta_info.emails).to eq(['a@a.com'])
      end
    end
  end
end
