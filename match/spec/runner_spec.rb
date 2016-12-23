describe Match do
  describe Match::Runner do
    it "creates a new profile and certificate if it doesn't exist yet" do
      git_url = "https://github.com/fastlane/fastlane/tree/master/certificates"
      values = {
        app_identifier: "tools.fastlane.app",
        type: "appstore",
        git_url: git_url,
        shallow_clone: true
      }

      config = FastlaneCore::Configuration.create(Match::Options.available_options, values)
      repo_dir = Dir.mktmpdir
      cert_path = File.join(repo_dir, "something")
      profile_path = "./match/spec/fixtures/test.mobileprovision"

      expect(Match::GitHelper).to receive(:clone).with(git_url, true, skip_docs: false, branch: "master").and_return(repo_dir)
      expect(Match::Generator).to receive(:generate_certificate).with(config, :distribution).and_return(cert_path)
      expect(Match::Generator).to receive(:generate_provisioning_profile).with(params: config,
                                                                            prov_type: :appstore,
                                                                       certificate_id: "something",
                                                                       app_identifier: values[:app_identifier]).and_return(profile_path)
      expect(FastlaneCore::ProvisioningProfile).to receive(:install).with(profile_path)
      expect(Match::GitHelper).to receive(:commit_changes).with(repo_dir, "[fastlane] Updated appstore", git_url, "master")

      spaceship = "spaceship"
      expect(Match::SpaceshipEnsure).to receive(:new).and_return(spaceship)
      expect(spaceship).to receive(:certificate_exists).and_return(true)
      expect(spaceship).to receive(:profile_exists).and_return(true)
      expect(spaceship).to receive(:bundle_identifier_exists).and_return(true)

      Match::Runner.new.run(config)
    end

    it "uses existing certificates and profiles if they exist" do
      git_url = "https://github.com/fastlane/fastlane/tree/master/certificates"
      values = {
        app_identifier: "tools.fastlane.app",
        type: "appstore",
        git_url: git_url
      }

      config = FastlaneCore::Configuration.create(Match::Options.available_options, values)
      repo_dir = "./match/spec/fixtures/existing"
      cert_path = "./match/spec/fixtures/existing/certs/distribution/E7P4EE896K.cer"
      key_path = "./match/spec/fixtures/existing/certs/distribution/E7P4EE896K.p12"
      keychain = "login.keychain"

      expect(Match::GitHelper).to receive(:clone).with(git_url, false, skip_docs: false, branch: "master").and_return(repo_dir)
      expect(Match::Utils).to receive(:import).with(key_path, keychain, password: nil).and_return(nil)
      expect(Match::GitHelper).to_not receive(:commit_changes)

      # To also install the certificate, fake that
      expect(FastlaneCore::CertChecker).to receive(:installed?).with(cert_path).and_return(false)
      expect(Match::Utils).to receive(:import).with(cert_path, keychain, password: nil).and_return(nil)

      spaceship = "spaceship"
      expect(Match::SpaceshipEnsure).to receive(:new).and_return(spaceship)
      expect(spaceship).to receive(:certificate_exists).and_return(true)
      expect(spaceship).to receive(:profile_exists).and_return(true)
      expect(spaceship).to receive(:bundle_identifier_exists).and_return(true)

      Match::Runner.new.run(config)
    end
  end
end
