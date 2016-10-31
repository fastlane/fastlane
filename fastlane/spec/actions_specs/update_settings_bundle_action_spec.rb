describe Fastlane do
  describe Fastlane::FastFile do
    describe "Update Settings Bundle Integration" do
      require 'shellwords'

      it "updates the current app version in the settings bundle" do
        require 'plist'

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
