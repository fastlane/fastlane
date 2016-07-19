describe Fastlane::Helper::CrashlyticsProjectHelper do
  describe 'parses .xcproject files' do
    it 'fetches keys from valid Crashlytics Beta project' do
      project_path = 'spec/fixtures/xcodeproj/crashlytics_beta_project.xcodeproj'
      helper = Fastlane::Helper::CrashlyticsProjectHelper.new('beta_test_2', project_path)
      expect(helper.values_found?).to eq(true)
      expect(helper.api_key).to eq('58371b79037c27a2dc1fb20f4d24b0661ab1cfe0')
      expect(helper.build_secret).to eq('5c77a9abe30efe3224cfb8a4134eb483fda73d4a65c7e27972bdaf5f326d2d95')
    end

    it ('fails if target_name is incorrect') do
      project_path = 'spec/fixtures/xcodeproj/crashlytics_beta_project.xcodeproj'
      expect do
        Fastlane::Helper::CrashlyticsProjectHelper.new('totally_not_a_target', project_path)
      end.to raise_error
    end

    it ('fails with project with no run script build phase') do
      project_path = 'spec/fixtures/xcodeproj/crashlytics_beta_project_no_run_script_build_phase.xcodeproj'
      expect do
        helper = Fastlane::Helper::CrashlyticsProjectHelper.new('beta_test_2', project_path)
      end.to raise_error
    end

    it ('finds no values in project with non-Crashlytics run script build phase') do
      project_path = 'spec/fixtures/xcodeproj/crashlytics_beta_project_invalid_run_script_build_phase.xcodeproj'
      helper = Fastlane::Helper::CrashlyticsProjectHelper.new('beta_test_2', project_path)
      expect(helper.values_found?).to eq(false)
    end
  end

end
