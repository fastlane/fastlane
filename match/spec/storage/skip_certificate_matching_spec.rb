describe Match::Storage do
  # `match import --skip_certificate_matching` is used without Developer Portal access
  describe "team folder with skip_certificate_matching" do
    let(:storage_values) do
      {
        "s3" => { s3_bucket: "bucket", s3_skip_encryption: true },
        "gitlab_secure_files" => { gitlab_project: "1", job_token: "token" },
        "google_cloud" => { google_cloud_bucket_name: "bucket" }
      }
    end

    before do
      ENV.delete('FASTLANE_TEAM_ID')
      ENV.delete('FASTLANE_TEAM_NAME')
      allow(Spaceship::ConnectAPI).to receive(:token).and_return(nil)

      # Google Cloud logs in when the storage is created
      allow_any_instance_of(Match::Storage::GoogleCloudStorage).to receive(:ensure_keys_file_exists).and_return("keys.json")
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with("keys.json").and_return('{"project_id":"project"}')
      allow(Google::Cloud::Storage).to receive(:new).and_return(double(bucket: double))
      allow_any_instance_of(Match::Storage::GoogleCloudStorage).to receive(:check_bucket_permissions)
    end

    def storage(mode, **values)
      config = FastlaneCore::Configuration.create(Match::Options.available_options, {
        app_identifier: "tools.fastlane.app",
        type: "appstore",
        storage_mode: mode,
        team_id: "TEAM123",
        username: "user@example.com"
      }.merge(storage_values[mode]).merge(values))
      config.option_for_key(:git_url).optional = true
      Match::Storage.from_params(config).tap do |storage|
        allow(storage).to receive(:working_directory).and_return("/repo")
      end
    end

    ["s3", "gitlab_secure_files", "google_cloud"].each do |mode|
      it "uses the given team_id without logging in to the portal for #{mode}" do
        expect(Match::SpaceshipEnsure).not_to receive(:new)

        expect(storage(mode, skip_certificate_matching: true).prefixed_working_directory).to eq("/repo/TEAM123")
      end

      it "still checks the team on the portal for #{mode} without it" do
        expect(Match::SpaceshipEnsure).to receive(:new).with("user@example.com", "TEAM123", nil, nil).and_return(double(team_id: "TEAM123"))

        expect(storage(mode).prefixed_working_directory).to eq("/repo/TEAM123")
      end
    end

    it "still falls back to all teams in readonly mode without team_id" do
      allow(UI).to receive(:important)
      expect(storage("s3", skip_certificate_matching: true, readonly: true, team_id: nil).prefixed_working_directory).to eq("/repo/*")
    end

    it "still requires team_id" do
      expect do
        storage("s3", skip_certificate_matching: true, team_id: nil).prefixed_working_directory
      end.to raise_error(FastlaneCore::Interface::FastlaneError, /team_id/)
    end
  end
end
