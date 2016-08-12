describe Fastlane::CrashlyticsBetaCommandLineHandler do
  describe 'creates a CrashlyticsBetaInfo from Options' do
    it 'Adds all the fields' do
      # Use a double so that we can detect both missing calls and unexpected calls
      options = double("fake_options")

      expect(options).to receive(:crashlytics_path).and_return('path/to/Crashlytics.framework')
      expect(options).to receive(:api_key).and_return('my_api_key')
      expect(options).to receive(:build_secret).and_return('my_build_secret')
      expect(options).to receive(:emails).and_return(['test@test.com', 'test2@test.com'])
      expect(options).to receive(:groups).and_return(['group1', 'group2'])
      expect(options).to receive(:scheme).at_least(:once).and_return('myScheme')
      expect(options).to receive(:export_method).and_return('development')

      beta_info = Fastlane::CrashlyticsBetaCommandLineHandler.info_from_options(options)

      expect(beta_info.crashlytics_path).to eq('path/to/Crashlytics.framework')
      expect(beta_info.api_key).to eq('my_api_key')
      expect(beta_info.build_secret).to eq('my_build_secret')
      expect(beta_info.emails).to eq(['test@test.com', 'test2@test.com'])
      expect(beta_info.groups).to eq(['group1', 'group2'])
      expect(beta_info.schemes).to eq(['myScheme'])
      expect(beta_info.export_method).to eq('development')
    end

    it 'Handles when no values for options are provided' do
      options = Commander::Command::Options.new

      beta_info = Fastlane::CrashlyticsBetaCommandLineHandler.info_from_options(options)

      expect(beta_info.crashlytics_path).to be_nil
      expect(beta_info.api_key).to be_nil
      expect(beta_info.build_secret).to be_nil
      expect(beta_info.emails).to be_nil
      expect(beta_info.schemes).to be_nil
      expect(beta_info.export_method).to be_nil
    end
  end

  describe 'applies options to a command' do
    it 'applies options' do
      # Use a double so that we can detect both missing calls and unexpected calls
      command = double("fake_command")

      expect(command).to receive(:option).with('--crashlytics_path STRING', String, kind_of(String))
      expect(command).to receive(:option).with('--api_key STRING', String, kind_of(String))
      expect(command).to receive(:option).with('--build_secret STRING', String, kind_of(String))
      expect(command).to receive(:option).with('--emails ARRAY', Array, kind_of(String))
      expect(command).to receive(:option).with('--groups ARRAY', Array, kind_of(String))
      expect(command).to receive(:option).with('--scheme STRING', String, kind_of(String))
      expect(command).to receive(:option).with('--export_method STRING', String, kind_of(String))

      Fastlane::CrashlyticsBetaCommandLineHandler.apply_options(command)
    end
  end
end
