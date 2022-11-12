describe Match do
  describe Match::Migrate do
    before do
      stub_const('ENV', { "MATCH_PASSWORD" => '2"QAHg@v(Qp{=*n^' })
    end

    it "deletes decrypted files at the end", requires_security: true do
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

      fake_google_cloud_storage = "fake_google_cloud_storage"
      expect(Match::Storage::GoogleCloudStorage).to receive(:configure).with(
        google_cloud_bucket_name: nil,
        google_cloud_keys_file: nil,
        google_cloud_project_id: nil
      ).and_return(fake_google_cloud_storage)

      allow(fake_google_cloud_storage).to receive(:download)
      allow(fake_google_cloud_storage).to receive(:save_changes!)
      allow(fake_google_cloud_storage).to receive(:bucket_name).and_return("")

      fake_git_storage = "fake_git_storage"
      expect(Match::Storage::GitStorage).to receive(:configure).with(
        git_url: git_url,
        shallow_clone: true,
        git_branch: "master",
        clone_branch_directly: false
      ).and_return(fake_git_storage)

      allow(fake_git_storage).to receive(:download)
      allow(fake_git_storage).to receive(:working_directory).and_return(repo_dir)

      spaceship = "spaceship"
      allow(spaceship).to receive(:team_id).and_return("team_id")
      allow(Match::SpaceshipEnsure).to receive(:new).and_return(spaceship)

      allow(UI).to receive(:input)

      expect(fake_google_cloud_storage).to receive(:clear_changes)
      expect(fake_git_storage).to receive(:clear_changes)

      Match::Migrate.new.migrate(config)
    end
  end
end
