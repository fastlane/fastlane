require 'spec_helper'

describe Fastlane do
  describe Fastlane::Actions::UpdateProjectTeamAction do
    describe "Update Project Team" do
      let(:fixtures_path) { "./fastlane/spec/fixtures" }
      let(:xcodeproj) { File.absolute_path(File.join(fixtures_path, 'xcodeproj', 'bundle.xcodeproj')) }

      it "updates the development team ID for all targets and configurations" do
        # We'll use a copy of the xcodeproj to avoid modifying the fixture
        temp_xcodeproj = File.join(Dir.tmpdir, "bundle.xcodeproj")
        FileUtils.cp_r(xcodeproj, temp_xcodeproj)

        begin
          Fastlane::Actions::UpdateProjectTeamAction.run(
            path: temp_xcodeproj,
            teamid: "NEWTEAM123"
          )

          project = Xcodeproj::Project.open(temp_xcodeproj)
          project.native_targets.each do |target|
            target.build_configurations.each do |config|
              expect(config.build_settings['DEVELOPMENT_TEAM']).to eq("NEWTEAM123")
            end
          end
        ensure
          FileUtils.rm_rf(temp_xcodeproj)
        end
      end

      it "updates conditional DEVELOPMENT_TEAM settings using a fixture" do
        temp_xcodeproj = File.join(Dir.tmpdir, "sdk-qualifier.xcodeproj")
        fixture_xcodeproj = File.join(fixtures_path, 'xcodeproj', 'sdk-qualifier.xcodeproj')
        FileUtils.cp_r(fixture_xcodeproj, temp_xcodeproj)

        begin
          Fastlane::Actions::UpdateProjectTeamAction.run(
            path: temp_xcodeproj,
            teamid: 'NEWTEAM456'
          )

          project = Xcodeproj::Project.open(temp_xcodeproj)
          project.native_targets.each do |target|
            target.build_configurations.each do |config|
              expect(config.build_settings['DEVELOPMENT_TEAM']).to eq('NEWTEAM456')
              expect(config.build_settings['DEVELOPMENT_TEAM[sdk=iphoneos*]']).to eq('NEWTEAM456')
            end
          end
        ensure
          FileUtils.rm_rf(temp_xcodeproj)
        end
      end

      it "works when only the base DEVELOPMENT_TEAM key exists" do
        temp_xcodeproj = File.join(Dir.tmpdir, "bundle-no-sdk.xcodeproj")
        FileUtils.cp_r(xcodeproj, temp_xcodeproj)

        begin
          # bundle.xcodeproj by default doesn't have DEVELOPMENT_TEAM,
          # but the action should set it if it doesn't exist.
          Fastlane::Actions::UpdateProjectTeamAction.run(
            path: temp_xcodeproj,
            teamid: 'NEWTEAM789'
          )

          project = Xcodeproj::Project.open(temp_xcodeproj)
          project.native_targets.each do |target|
            target.build_configurations.each do |config|
              expect(config.build_settings['DEVELOPMENT_TEAM']).to eq('NEWTEAM789')
              # Ensure no other DEVELOPMENT_TEAM keys were created
              sdk_keys = config.build_settings.keys.select { |k| k.to_s.start_with?("DEVELOPMENT_TEAM") && k != "DEVELOPMENT_TEAM" }
              expect(sdk_keys).to be_empty
            end
          end
        ensure
          FileUtils.rm_rf(temp_xcodeproj)
        end
      end
    end
  end
end
