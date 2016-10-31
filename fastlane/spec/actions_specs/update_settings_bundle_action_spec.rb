describe Fastlane do
  describe Fastlane::FastFile do
    describe "Update Settings Bundle Integration" do

      it "updates the current app version in the settings bundle" do
        require 'plist'

        plist = {
          "PreferenceSpecifiers" => [
            {
              "Key" => "CurrentAppVersion"
            }
          ]
        }

        expected = {
          "PreferenceSpecifiers" => [
            {
              "Key" => "CurrentAppVersion",
              "DefaultValue" => "1.0.0 (1)"
            }
          ]
        }

        path = "Resources/Settings.bundle/Root.plist"

        allow(Plist).to receive(:parse_xml).and_return plist
        allow(Plist::Emit).to receive(:save_plist).with(expected, path)

        lane = <<-EOF
          lane :test do
            Actions.lane_context[:VERSION_NUMBER] = "1.0.0"
            Actions.lane_context[:BUILD_NUMBER] = "1"
            update_settings_bundle path: "#{path}",
              setting_key: "CurrentAppVersion"
          end
        EOF

        Fastlane::FastFile.new.parse(lane).runner.execute(:test)

      end
    end
  end
end
