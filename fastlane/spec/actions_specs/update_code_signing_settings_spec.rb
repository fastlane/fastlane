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

      # A directory of its own: Dir.tmpdir is the shared temp root, so parallel test processes would collide. See fastlane#30184.
      temp_dir = Dir.mktmpdir('fl_spec_update_code_signing')
      FileUtils.copy_entry(unmodified_project_path, temp_dir)

      project_path = temp_dir
    end

    describe "Update Code Signing Settings" do
      before :each do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
      end

      it "raises a readable error when the path has no project file" do
        empty_project_path = Dir.mktmpdir("fl_spec_update_code_signing_empty")
        project_file_path = File.join(empty_project_path, "project.pbxproj")

        expect do
          Fastlane::FastFile.new.parse("lane :test do
            update_code_signing_settings(use_automatic_signing: true, path: '#{empty_project_path}')
          end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, /Could not find path to project config '#{Regexp.escape(project_file_path)}'/)
      end

      it "accepts a project in Xcode's JSON format, which has no TargetAttributes" do
        json_project_path = File.join(Dir.mktmpdir("fl_spec_update_code_signing_json"), "App.xcodeproj")
        FileUtils.mkdir_p(json_project_path)
        FileUtils.touch(File.join(json_project_path, "project.xcproj"))
        project = Xcodeproj::Project.new(json_project_path)
        project.new_target(:application, "App", :ios)
        project.root_object.attributes.delete("TargetAttributes")
        # Opening a JSON format project needs a newer xcodeproj gem, which has this module
        stub_const("Xcodeproj::Project::JSONFormat", Module.new)
        allow(Xcodeproj::Project).to receive(:open).with(json_project_path).and_return(project)
        expect(project).to receive(:save)

        result = Fastlane::FastFile.new.parse("lane :test do
          update_code_signing_settings(use_automatic_signing: true, path: '#{json_project_path}')
        end").runner.execute(:test)

        expect(result).to eq(true)
        expect(project.targets.first.build_configurations.map { |config| config.build_settings["CODE_SIGN_STYLE"] }).to eq(["Automatic", "Automatic"])
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
