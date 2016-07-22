describe Fastlane::CrashlyticsProjectParser do
  describe 'parses .xcproject files' do
    it 'fetches path & keys from valid Crashlytics Beta project' do
      project_path = 'spec/fixtures/xcodeproj/crashlytics_beta_project.xcodeproj'
      parser = Fastlane::CrashlyticsProjectParser.new('beta_test_2', project_path)
      values = parser.parse
      expect(values[:crashlytics_path]).to eq('./Crashlytics.framework')
      expect(values[:api_key]).to eq('0123456789012345678901234567890123456789')
      expect(values[:build_secret]).to eq('0123456789012345678901234567890123456789012345678901234567890123')
    end

    it 'fails if project_file_path is invalid' do
      project_path = 'totally/not/a/path'
      expect do
        Fastlane::CrashlyticsProjectParser.new('beta_test_2', project_path).parse
      end.to raise_error
    end

    it 'fails if target_name is invalid' do
      project_path = 'spec/fixtures/xcodeproj/crashlytics_beta_project.xcodeproj'
      expect do
        Fastlane::CrashlyticsProjectParser.new('totally_not_a_target', project_path).parse
      end.to raise_error
    end

    it 'fails with project with no run script build phase' do
      project_path = 'spec/fixtures/xcodeproj/crashlytics_beta_project_no_run_script_build_phase.xcodeproj'
      expect do
        Fastlane::CrashlyticsProjectParser.new('beta_test_2', project_path).parse
      end.to raise_error
    end

    it 'finds no values in project with non-Crashlytics run script build phase' do
      project_path = 'spec/fixtures/xcodeproj/crashlytics_beta_project_invalid_run_script_build_phase.xcodeproj'
      parser = Fastlane::CrashlyticsProjectParser.new('beta_test_2', project_path)
      expect(parser.parse).to be_nil
    end
  end

end
