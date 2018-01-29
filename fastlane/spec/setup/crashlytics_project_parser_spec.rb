describe Fastlane::CrashlyticsProjectParser do
  describe 'parses .xcproject files' do
    it 'fetches path & keys from valid Crashlytics Beta project', requires_xcode: true do
      project_path = './fastlane/spec/fixtures/xcodeproj/crashlytics_beta_project.xcodeproj'
      parser = Fastlane::CrashlyticsProjectParser.new({ project: project_path })
      values = parser.parse
      expect(values[:crashlytics_path]).to eq('./Crashlytics.framework')
      expect(values[:api_key]).to eq('0123456789012345678901234567890123456789')
      expect(values[:build_secret]).to eq('0123456789012345678901234567890123456789012345678901234567890123')
    end

    it 'fails if project_file_path is invalid' do
      project_path = 'totally/not/a/path'
      expect do
        Fastlane::CrashlyticsProjectParser.new({ project: project_path }).parse
      end.to raise_error(/Could not find project at path/)
    end

    it 'fails if target_name is invalid', requires_xcodebuild: true do
      project_path = './fastlane/spec/fixtures/xcodeproj/crashlytics_beta_project.xcodeproj'
      project = FastlaneCore::Project.new(
        { project: project_path },
        xcodebuild_list_silent: true,
        xcodebuild_suppress_stderr: true
      )
      expect(project).to receive(:default_build_settings).and_return('invalid_target_name')
      expect(FastlaneCore::Project).to receive(:new).and_return(project)

      expect do
        Fastlane::CrashlyticsProjectParser.new({ project: project_path }).parse
      end.to raise_error("Unable to locate a target by the name of invalid_target_name")
    end

    it 'fails with project with no run script build phase', requires_xcode: true do
      project_path = './fastlane/spec/fixtures/xcodeproj/crashlytics_beta_project_no_run_script_build_phase.xcodeproj'
      expect do
        Fastlane::CrashlyticsProjectParser.new({ project: project_path }).parse
      end.to raise_error("Unable to find Crashlytics Run Script Build Phase")
    end

    it 'finds no values in project with non-Crashlytics run script build phase', requires_xcode: true do
      project_path = './fastlane/spec/fixtures/xcodeproj/crashlytics_beta_project_invalid_run_script_build_phase.xcodeproj'
      parser = Fastlane::CrashlyticsProjectParser.new({ project: project_path })
      expect(parser.parse).to eq({ schemes: [] })
    end

    it 'returns 2 schemes from a project', requires_xcode: true do
      # We have to name this file all obfuscated-like (skeem) because FastlaneCore::Project
      # will reject any value that includes the word 'scheme'
      project_path = './fastlane/spec/fixtures/xcodeproj/crashlytics_beta_project_two_skeems.xcodeproj'
      parser = Fastlane::CrashlyticsProjectParser.new({ project: project_path })
      values = parser.parse

      expect(values[:crashlytics_path]).to eq('./Crashlytics.framework')
      expect(values[:api_key]).to eq('0123456789012345678901234567890123456789')
      expect(values[:build_secret]).to eq('0123456789012345678901234567890123456789012345678901234567890123')
      expect(values[:schemes]).to eq(['beta_test_2', 'beta_test_2_second'])
    end
  end
end
