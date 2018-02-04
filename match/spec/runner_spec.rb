describe Match do
  describe Match::Runner do
    let(:keychain) { 'login.keychain' }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('MATCH_KEYCHAIN_NAME').and_return(keychain)
      allow(ENV).to receive(:[]).with('MATCH_KEYCHAIN_PASSWORD').and_return(nil)
    end

    it "creates a new profile and certificate if it doesn't exist yet", requires_security: true do
      git_url = "https://github.com/fastlane/fastlane/tree/master/certificates"
      values = {
        app_identifier: "tools.fastlane.app",
        type: "appstore",
        git_url: git_url,
        shallow_clone: true
      }

      config = FastlaneCore::Configuration.create(Match::Options.available_options, values)
      repo_dir = Dir.mktmpdir
      cert_path = File.join(repo_dir, "something.cer")
      profile_path = "./match/spec/fixtures/test.mobileprovision"
      destination = File.expand_path("~/Library/MobileDevice/Provisioning Profiles/98264c6b-5151-4349-8d0f-66691e48ae35.mobileprovision")

      expect(Match::GitHelper).to receive(:clone).with(git_url, true, skip_docs: false, branch: "master", git_full_name: nil, git_user_email: nil, clone_branch_directly: false).and_return(repo_dir)
      expect(Match::Generator).to receive(:generate_certificate).with(config, :distribution).and_return(cert_path)
      expect(Match::Generator).to receive(:generate_provisioning_profile).with(params: config,
                                                                            prov_type: :appstore,
                                                                       certificate_id: "something",
                                                                       app_identifier: values[:app_identifier]).and_return(profile_path)
      expect(FastlaneCore::ProvisioningProfile).to receive(:install).with(profile_path).and_return(destination)
      expect(Match::GitHelper).to receive(:commit_changes).with(
        repo_dir,
        "[fastlane] Updated appstore and platform ios",
        git_url,
        "master",
        [
          File.join(repo_dir, "something.cer"),
          File.join(repo_dir, "something.p12"), # this is important, as a cert consists out of 2 files
          "./match/spec/fixtures/test.mobileprovision"
        ]
      )

      spaceship = "spaceship"
      expect(Match::SpaceshipEnsure).to receive(:new).and_return(spaceship)
      expect(spaceship).to receive(:certificate_exists).and_return(true)
      expect(spaceship).to receive(:profile_exists).and_return(true)
      expect(spaceship).to receive(:bundle_identifier_exists).and_return(true)

      Match::Runner.new.run(config)

      expect(ENV[Match::Utils.environment_variable_name(app_identifier: "tools.fastlane.app",
                                                        type: "appstore")]).to eql('98264c6b-5151-4349-8d0f-66691e48ae35')
      expect(ENV[Match::Utils.environment_variable_name_team_id(app_identifier: "tools.fastlane.app",
                                                                type: "appstore")]).to eql('439BBM9367')
      expect(ENV[Match::Utils.environment_variable_name_profile_name(app_identifier: "tools.fastlane.app",
                                                                     type: "appstore")]).to eql('tools.fastlane.app AppStore')
      profile_path = File.expand_path('~/Library/MobileDevice/Provisioning Profiles/98264c6b-5151-4349-8d0f-66691e48ae35.mobileprovision')
      expect(ENV[Match::Utils.environment_variable_name_profile_path(app_identifier: "tools.fastlane.app",
                                                                     type: "appstore")]).to eql(profile_path)
    end

    it "uses existing certificates and profiles if they exist", requires_security: true do
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

      expect(Match::GitHelper).to receive(:clone).with(git_url, false, skip_docs: false, branch: "master", git_full_name: nil, git_user_email: nil, clone_branch_directly: false).and_return(repo_dir)
      expect(Match::Utils).to receive(:import).with(key_path, keychain, password: nil).and_return(nil)
      expect(Match::GitHelper).to_not(receive(:commit_changes))

      # To also install the certificate, fake that
      expect(FastlaneCore::CertChecker).to receive(:installed?).with(cert_path).and_return(false)
      expect(Match::Utils).to receive(:import).with(cert_path, keychain, password: nil).and_return(nil)

      spaceship = "spaceship"
      expect(Match::SpaceshipEnsure).to receive(:new).and_return(spaceship)
      expect(spaceship).to receive(:certificate_exists).and_return(true)
      expect(spaceship).to receive(:profile_exists).and_return(true)
      expect(spaceship).to receive(:bundle_identifier_exists).and_return(true)

      Match::Runner.new.run(config)

      expect(ENV[Match::Utils.environment_variable_name(app_identifier: "tools.fastlane.app",
                                                        type: "appstore")]).to eql('736590c3-dfe8-4c25-b2eb-2404b8e65fb8')
      expect(ENV[Match::Utils.environment_variable_name_team_id(app_identifier: "tools.fastlane.app",
                                                                type: "appstore")]).to eql('439BBM9367')
      expect(ENV[Match::Utils.environment_variable_name_profile_name(app_identifier: "tools.fastlane.app",
                                                                     type: "appstore")]).to eql('match AppStore tools.fastlane.app 1449198835')
      profile_path = File.expand_path('~/Library/MobileDevice/Provisioning Profiles/736590c3-dfe8-4c25-b2eb-2404b8e65fb8.mobileprovision')
      expect(ENV[Match::Utils.environment_variable_name_profile_path(app_identifier: "tools.fastlane.app",
                                                                     type: "appstore")]).to eql(profile_path)
    end
  end
end
