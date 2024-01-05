require "xcodeproj"
# 771D79501D9E69C900D840FA = demo
# 77C503031DD3175E00AC8FF0 = today
describe Fastlane do
  describe Fastlane::FastFile do
    let(:project_path_old) do
      "./fastlane/spec/fixtures/xcodeproj/update-code-signing-settings-old.xcodeproj"
    end

    let(:unmodified_project_path) do
      "./fastlane/spec/fixtures/xcodeproj/update-code-signing-settings.xcodeproj"
    end

    project_path = nil

    before :each do
      ENV.delete("FASTLANE_TEAM_ID")

      temp_dir = Dir.tmpdir
      FileUtils.copy_entry(unmodified_project_path, temp_dir)

      project_path = temp_dir
    end

    describe "Update Code Signing Settings" do
      before :each do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
      end

      it "Automatic code signing" do
        allow(UI).to receive(:success)
        expect(UI).to receive(:success).with("Successfully updated project settings to use Code Sign Style = 'Automatic'")
        result = Fastlane::FastFile.new.parse("lane :test do
          update_code_signing_settings(use_automatic_signing: true, path: '#{project_path}', team_id: 'XXXX')
        end").runner.execute(:test)
        expect(result).to eq(true)

        project = Xcodeproj::Project.open(project_path)
        project.targets.each do |target|
          target.build_configuration_list.get_setting("CODE_SIGN_STYLE").map do |build_config, value|
            expect(value).to eq("Automatic")
          end
        end
      end

      it "Manual code signing for specific target" do
        allow(UI).to receive(:success)
        expect(UI).to receive(:success).with("Successfully updated project settings to use Code Sign Style = 'Manual'")
        expect(UI).to receive(:success).with("\t * today")
        expect(UI).to receive(:important).with("Skipping demo not selected (today)")
        result = Fastlane::FastFile.new.parse("lane :test do
          update_code_signing_settings(use_automatic_signing: false, path: '#{project_path}', targets: ['today'])
        end").runner.execute(:test)
        expect(result).to eq(false)

        project = Xcodeproj::Project.open(project_path)
        project.targets.each do |target|
          target.build_configuration_list.get_setting("CODE_SIGN_STYLE").map do |build_config, value|
            expect(value).to eq(target.name == 'today' ? "Manual" : "Automatic")
          end
        end
      end

      it "Manual code signing" do
        allow(UI).to receive(:success)
        expect(UI).to receive(:success).with("Successfully updated project settings to use Code Sign Style = 'Manual'")
        result = Fastlane::FastFile.new.parse("lane :test do
          update_code_signing_settings(use_automatic_signing: false, path: '#{project_path}')
        end").runner.execute(:test)
        expect(result).to eq(false)

        project = Xcodeproj::Project.open(project_path)
        project.targets.each do |target|
          target.build_configuration_list.get_setting("CODE_SIGN_STYLE").map do |build_config, value|
            expect(value).to eq("Manual")
          end
        end
      end

      it "sets team id" do
        # G3KGXDXQL9
        allow(UI).to receive(:success)
        expect(UI).to receive(:success).with("Successfully updated project settings to use Code Sign Style = 'Manual'")

        ["Debug", "Release"].each do |configuration|
          expect(UI).to receive(:important).with("Set Team id to: G3KGXDXQL9 for target: demo for build configuration: #{configuration}")
          expect(UI).to receive(:important).with("Set Team id to: G3KGXDXQL9 for target: today for build configuration: #{configuration}")
        end

        result = Fastlane::FastFile.new.parse("lane :test do
          update_code_signing_settings(use_automatic_signing: false, path: '#{project_path}', team_id: 'G3KGXDXQL9')
        end").runner.execute(:test)
        expect(result).to eq(false)

        project = Xcodeproj::Project.open(project_path)
        project.targets.each do |target|
          target.build_configuration_list.get_setting("CODE_SIGN_STYLE").map do |build_config, value|
            expect(value).to eq("Manual")
          end
        end
      end

      it "sets code sign identity" do
        # G3KGXDXQL9
        allow(UI).to receive(:success)
        expect(UI).to receive(:success).with("Successfully updated project settings to use Code Sign Style = 'Manual'")

        ["Debug", "Release"].each do |configuration|
          expect(UI).to receive(:important).with("Set Team id to: G3KGXDXQL9 for target: demo for build configuration: #{configuration}")
          expect(UI).to receive(:important).with("Set Team id to: G3KGXDXQL9 for target: today for build configuration: #{configuration}")
          expect(UI).to receive(:important).with("Set Code Sign identity to: iPhone Distribution for target: demo for build configuration: #{configuration}")
          expect(UI).to receive(:important).with("Set Code Sign identity to: iPhone Distribution for target: today for build configuration: #{configuration}")
        end

        result = Fastlane::FastFile.new.parse("lane :test do
          update_code_signing_settings(use_automatic_signing: false, path: '#{project_path}', team_id: 'G3KGXDXQL9', code_sign_identity: 'iPhone Distribution')
        end").runner.execute(:test)
        expect(result).to eq(false)

        project = Xcodeproj::Project.open(project_path)
        project.targets.each do |target|
          target.build_configuration_list.get_setting("CODE_SIGN_STYLE").map do |build_config, value|
            expect(value).to eq("Manual")
          end
          target.build_configuration_list.get_setting("CODE_SIGN_IDENTITY").map do |build_config, value|
            expect(value).to eq("iPhone Distribution")
          end
        end
      end

      it "sets code sign entitlements file" do
        # G3KGXDXQL9
        allow(UI).to receive(:success)
        expect(UI).to receive(:success).with("Successfully updated project settings to use Code Sign Style = 'Manual'")

        ["Debug", "Release"].each do |configuration|
          expect(UI).to receive(:important).with("Set Team id to: G3KGXDXQL9 for target: demo for build configuration: #{configuration}")
          expect(UI).to receive(:important).with("Set Team id to: G3KGXDXQL9 for target: today for build configuration: #{configuration}")
          expect(UI).to receive(:important).with("Set Entitlements file path to: Test.entitlements for target: demo for build configuration: #{configuration}")
          expect(UI).to receive(:important).with("Set Entitlements file path to: Test.entitlements for target: today for build configuration: #{configuration}")
        end

        result = Fastlane::FastFile.new.parse("lane :test do
          update_code_signing_settings(use_automatic_signing: false, path: '#{project_path}', team_id: 'G3KGXDXQL9', entitlements_file_path: 'Test.entitlements')
        end").runner.execute(:test)
        expect(result).to eq(false)

        project = Xcodeproj::Project.open(project_path)
        project.targets.each do |target|
          target.build_configuration_list.get_setting("CODE_SIGN_STYLE").map do |build_config, value|
            expect(value).to eq("Manual")
          end
          target.build_configuration_list.get_setting("CODE_SIGN_ENTITLEMENTS").map do |build_config, value|
            expect(value).to eq("Test.entitlements")
          end
        end
      end

      it "sets profile name" do
        # G3KGXDXQL9
        allow(UI).to receive(:success)
        expect(UI).to receive(:success).with("Successfully updated project settings to use Code Sign Style = 'Manual'")

        ["Debug", "Release"].each do |configuration|
          expect(UI).to receive(:important).with("Set Team id to: G3KGXDXQL9 for target: demo for build configuration: #{configuration}")
          expect(UI).to receive(:important).with("Set Team id to: G3KGXDXQL9 for target: today for build configuration: #{configuration}")
          expect(UI).to receive(:important).with("Set Provisioning Profile name to: Mindera for target: demo for build configuration: #{configuration}")
          expect(UI).to receive(:important).with("Set Provisioning Profile name to: Mindera for target: today for build configuration: #{configuration}")
        end

        result = Fastlane::FastFile.new.parse("lane :test do
          update_code_signing_settings(use_automatic_signing: false, path: '#{project_path}', team_id: 'G3KGXDXQL9', profile_name: 'Mindera')
        end").runner.execute(:test)
        expect(result).to eq(false)

        project = Xcodeproj::Project.open(project_path)
        project.targets.each do |target|
          target.build_configuration_list.get_setting("CODE_SIGN_STYLE").map do |build_config, value|
            expect(value).to eq("Manual")
          end
          target.build_configuration_list.get_setting("PROVISIONING_PROFILE_SPECIFIER").map do |build_config, value|
            expect(value).to eq("Mindera")
          end
        end
      end

      it "sets profile uuid" do
        # G3KGXDXQL9
        allow(UI).to receive(:success)
        expect(UI).to receive(:success).with("Successfully updated project settings to use Code Sign Style = 'Manual'")

        ["Debug", "Release"].each do |configuration|
          expect(UI).to receive(:important).with("Set Team id to: G3KGXDXQL9 for target: demo for build configuration: #{configuration}")
          expect(UI).to receive(:important).with("Set Team id to: G3KGXDXQL9 for target: today for build configuration: #{configuration}")
          expect(UI).to receive(:important).with("Set Provisioning Profile UUID to: 1337 for target: demo for build configuration: #{configuration}")
          expect(UI).to receive(:important).with("Set Provisioning Profile UUID to: 1337 for target: today for build configuration: #{configuration}")
        end

        result = Fastlane::FastFile.new.parse("lane :test do
          update_code_signing_settings(use_automatic_signing: false, path: '#{project_path}', team_id: 'G3KGXDXQL9', profile_uuid: '1337')
        end").runner.execute(:test)
        expect(result).to eq(false)

        project = Xcodeproj::Project.open(project_path)
        project.targets.each do |target|
          target.build_configuration_list.get_setting("CODE_SIGN_STYLE").map do |build_config, value|
            expect(value).to eq("Manual")
          end
          target.build_configuration_list.get_setting("PROVISIONING_PROFILE").map do |build_config, value|
            expect(value).to eq("1337")
          end
        end
      end

      it "sets bundle identifier" do
        # G3KGXDXQL9
        allow(UI).to receive(:success)
        expect(UI).to receive(:success).with("Successfully updated project settings to use Code Sign Style = 'Manual'")

        ["Debug", "Release"].each do |configuration|
          expect(UI).to receive(:important).with("Set Team id to: G3KGXDXQL9 for target: demo for build configuration: #{configuration}")
          expect(UI).to receive(:important).with("Set Team id to: G3KGXDXQL9 for target: today for build configuration: #{configuration}")
          expect(UI).to receive(:important).with("Set Bundle identifier to: com.fastlane.mindera.cosigner for target: demo for build configuration: #{configuration}")
          expect(UI).to receive(:important).with("Set Bundle identifier to: com.fastlane.mindera.cosigner for target: today for build configuration: #{configuration}")
        end

        result = Fastlane::FastFile.new.parse("lane :test do
          update_code_signing_settings(use_automatic_signing: false, path: '#{project_path}', team_id: 'G3KGXDXQL9', bundle_identifier: 'com.fastlane.mindera.cosigner')
        end").runner.execute(:test)
        expect(result).to eq(false)

        project = Xcodeproj::Project.open(project_path)
        project.targets.each do |target|
          target.build_configuration_list.get_setting("CODE_SIGN_STYLE").map do |build_config, value|
            expect(value).to eq("Manual")
          end
          target.build_configuration_list.get_setting("PRODUCT_BUNDLE_IDENTIFIER").map do |build_config, value|
            expect(value).to eq("com.fastlane.mindera.cosigner")
          end
        end
      end

      it "targets not found notice" do
        allow(UI).to receive(:important)
        expect(UI).to receive(:important).with("None of the specified targets has been modified")
        result = Fastlane::FastFile.new.parse("lane :test do
          update_code_signing_settings(use_automatic_signing: false, path: '#{project_path}', targets: ['not_found'])
        end").runner.execute(:test)
        expect(result).to eq(false)
      end

      it "raises exception on old projects" do
        expect(UI).to receive(:user_error!).with("Seems to be a very old project file format - please open your project file in a more recent version of Xcode")
        result = Fastlane::FastFile.new.parse("lane :test do
          update_code_signing_settings(use_automatic_signing: false, path: '#{project_path_old}')
        end").runner.execute(:test)
        expect(result).to eq(false)
      end
    end
  end
end
