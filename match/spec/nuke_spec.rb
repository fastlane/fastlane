describe Match do
  describe Match::Nuke do
    before do
      allow(Spaceship::ConnectAPI).to receive(:login).and_return(nil)
      allow(Spaceship::ConnectAPI).to receive(:client).and_return("client")
      allow(Spaceship::ConnectAPI.client).to receive(:in_house?).and_return(false)
      allow(Spaceship::ConnectAPI.client).to receive(:portal_team_id).and_return(nil)

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

      fake_storage = "fake_storage"
      expect(Match::Storage::GitStorage).to receive(:configure).with(
        git_url: git_url,
        shallow_clone: true,
        skip_docs: false,
        git_branch: "master",
        git_full_name: nil,
        git_user_email: nil,

        git_private_key: nil,
        git_basic_authorization: nil,
        git_bearer_authorization: nil,

        clone_branch_directly: false,

        type: config[:type],
        platform: config[:platform]
      ).and_return(fake_storage)

      allow(fake_storage).to receive(:download)
      allow(fake_storage).to receive(:working_directory).and_return(repo_dir)

      nuke = Match::Nuke.new

      allow(nuke).to receive(:prepare_list)
      allow(nuke).to receive(:filter_by_cert)
      allow(nuke).to receive(:print_tables)

      allow(nuke).to receive(:certs).and_return([])
      allow(nuke).to receive(:profiles).and_return([])
      allow(nuke).to receive(:files).and_return([])

      expect(fake_storage).to receive(:clear_changes)

      nuke.run(config, type: config[:type])
    end
  end
end
