describe Match do
  describe Match::Runner do
    it "creates a new profile and certificate if it doesn't exist yet" do
      git_url = "https://github.com/fastlane/certificates"
      values = {
        app_identifier: "tools.fastlane.app",
        type: "appstore",
        git_url: git_url
      }

      config = FastlaneCore::Configuration.create(Match::Options.available_options, values)
      tmp_dir = Dir.mktmpdir
      cert_path = File.join(tmp_dir, "something")
      profile_path = "./spec/fixtures/test.mobileprovision"

      expect(Match::GitHelper).to receive(:clone).with(git_url).and_return(tmp_dir)
      expect(Match::Generator).to receive(:generate_certificate).with(config, :distribution).and_return(cert_path)
      expect(Match::Generator).to receive(:generate_provisioning_profile).with(config, :appstore, cert_path).and_return(profile_path)
      expect(FastlaneCore::ProvisioningProfile).to receive(:install).with(profile_path)
      expect(Match::GitHelper).to receive(:commit_changes).with(tmp_dir, "[fastlane] Updated tools.fastlane.app for appstore")

      Match::Runner.new.run(config)
    end
  end
end