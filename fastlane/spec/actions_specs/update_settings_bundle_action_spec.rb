describe Fastlane do
  describe Fastlane::FastFile do
    describe "Update Settings Bundle Integration" do

      it "updates the current app version in the settings bundle" do
        pending "Not finished yet"

        require 'plist'

        plist = {
          "PreferenceSpecifiers" => [
            {
              "Key" => "CurrentAppVersion"
            }
          ]
        }

        allow(Plist).to receive(:parse_xml).and_return plist
        allow(Plist::Emit).to receive(:save_plist)

        lane = <<-EOF
          lane :test do
            update_settings_bundle path: "Resources/Settings.bundle/Root.plist",
              setting_key: "CurrentAppVersion"
          end
        EOF

        Fastlane::FastFile.new.parse(lane).runner.execute(:test)

      end
    end
  end
end
