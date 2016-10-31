describe Fastlane do
  describe Fastlane::FastFile do
    describe "Update Settings Bundle Integration" do

      it "updates the current app version in the settings bundle" do
        require 'plist'

        path = "Resources/Settings.bundle/Root.plist"
        setting_key = "CurrentAppVersion"

        plist = {
          "PreferenceSpecifiers" => [
            {
              "Key" => setting_key
            }
          ]
        }

        expected = {
          "PreferenceSpecifiers" => [
            {
              "Key" => setting_key,
              "DefaultValue" => "1.0.0 (1)"
            }
          ]
        }

        allow(Plist).to receive(:parse_xml).and_return plist
        allow(Plist::Emit).to receive(:save_plist).with(expected, path)

        lane = <<-EOF
          lane :test do
            Actions.lane_context[:VERSION_NUMBER] = "1.0.0"
            Actions.lane_context[:BUILD_NUMBER] = "1"
            update_settings_bundle path: "#{path}",
              setting_key: "#{setting_key}"
          end
        EOF

        Fastlane::FastFile.new.parse(lane).runner.execute(:test)

      end
    end
  end
end
