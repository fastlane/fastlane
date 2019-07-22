describe Match do
  describe Match::Runner do
    let(:keychain) { 'login.keychain' }
    let(:mock_cert) { double }
    let(:cert_path) { "./match/spec/fixtures/test.cer" }
    let(:p12_path) { "./match/spec/fixtures/test.p12" }

    before do
      allow(mock_cert).to receive(:id).and_return("123456789")
      allow(mock_cert).to receive(:certificate_content).and_return(Base64.strict_encode64(File.open(cert_path).read))

      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('MATCH_KEYCHAIN_NAME').and_return(keychain)
      allow(ENV).to receive(:[]).with('MATCH_KEYCHAIN_PASSWORD').and_return(nil)

      allow(ENV).to receive(:[]).with('MATCH_PASSWORD').and_return("test")

      ENV.delete('FASTLANE_TEAM_ID')
      ENV.delete('FASTLANE_TEAM_NAME')
    end

    it "imports a .cert and .p12 into the match repo", requires_security: true do
      git_url = "https://github.com/fastlane/fastlane/tree/master/certificates"
      values = {
        app_identifier: "tools.fastlane.app",
        type: "appstore",
        git_url: git_url,
        shallow_clone: true,
        username: "flapple@something.com"
      }

      config = FastlaneCore::Configuration.create(Match::Options.available_options, values)
      repo_dir = Dir.mktmpdir

      fake_storage = "fake_storage"
      expect(Match::Storage::GitStorage).to receive(:configure).with(
        git_url: git_url,
        shallow_clone: true,
        skip_docs: false,
        git_branch: "master",
        git_full_name: nil,
        git_user_email: nil,
        clone_branch_directly: false,
        type: config[:type],
        platform: config[:platform],
        google_cloud_bucket_name: "",
        google_cloud_keys_file: "",
        google_cloud_project_id: "",
        readonly: false,
        username: values[:username],
        team_id: nil,
        team_name: nil
      ).and_return(fake_storage)

      expect(fake_storage).to receive(:download).and_return(nil)
      allow(fake_storage).to receive(:working_directory).and_return(repo_dir)
      allow(fake_storage).to receive(:prefixed_working_directory).and_return(repo_dir)

      expect(Spaceship::Portal).to receive(:login)
      expect(Spaceship::Portal).to receive(:select_team)
      expect(Spaceship::ConnectAPI::Certificate).to receive(:all).and_return([mock_cert])

      expect(fake_storage).to receive(:save_changes!).with(
        files_to_commit: [
          File.join(repo_dir, "certs", "distribution", "#{mock_cert.id}.cer"),
          File.join(repo_dir, "certs", "distribution", "#{mock_cert.id}.p12")
        ]
      )

      Match::Importer.new.import_cert(config, cert_path: cert_path, p12_path: p12_path)
    end
  end
end
