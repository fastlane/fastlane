describe Match do
  describe Match::Nuke do
    def nuke_with_certificates(certificate_id: "1111111111")
      nuke = Match::Nuke.new
      nuke.params = {
        force: true,
        certificate_id: certificate_id
      }

      selected_cert = double("selected_cert", id: "1111111111")
      other_cert = double("other_cert", id: "2222222222")
      selected_profile = double("selected_profile", certificates: [selected_cert], profile_content: Base64.encode64("selected profile"))
      other_profile = double("other_profile", certificates: [other_cert], profile_content: Base64.encode64("other profile"))

      nuke.certs = [selected_cert, other_cert]
      nuke.profiles = [selected_profile, other_profile]
      nuke.files = [
        "/tmp/certs/distribution/1111111111.cer",
        "/tmp/certs/distribution/2222222222.cer",
        "/tmp/certs/distribution/1111111111.p12",
        "/tmp/certs/distribution/2222222222.p12",
        "/tmp/profiles/appstore/selected.mobileprovision",
        "/tmp/profiles/appstore/other.mobileprovision"
      ]

      allow(FastlaneCore::ProvisioningProfile).to receive(:uuid) do |path|
        case path
        when /selected\.mobileprovision$/
          "selected-profile-uuid"
        when /other\.mobileprovision$/
          "other-profile-uuid"
        else
          File.read(path) == "selected profile" ? "selected-profile-uuid" : "other-profile-uuid"
        end
      end

      nuke
    end

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
      expect(Match::Storage::GitStorage).to receive(:configure).with({
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
      }).and_return(fake_storage)

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

    it "uses certificate_id to filter certificates, profiles, and files when force is enabled" do
      nuke = nuke_with_certificates

      nuke.filter_by_cert

      expected_files = [
        "/tmp/certs/distribution/1111111111.cer",
        "/tmp/certs/distribution/1111111111.p12",
        "/tmp/profiles/appstore/selected.mobileprovision"
      ]

      expect(nuke.certs.map(&:id)).to eq(["1111111111"])
      expect(nuke.profiles.map { |profile| profile.certificates.first.id }).to eq(["1111111111"])
      expect(nuke.files).to eq(expected_files)
    end

    it "raises an explicit error when certificate_id does not match a fetched certificate" do
      nuke = nuke_with_certificates(certificate_id: "3333333333")

      expect do
        nuke.filter_by_cert
      end.to raise_error(FastlaneCore::Interface::FastlaneError, "No certificate found for certificate_id '3333333333'")
    end

    describe "skip_confirmation" do
      it "honors skip_confirmation: true in filter_by_cert" do
        nuke = Match::Nuke.new
        nuke.params = {
          skip_confirmation: true
        }
        cert = double("cert", id: "123", name: "cert", expiration_date: "2026-05-09T09:41:00+00:00")
        allow(cert).to receive(:class).and_return(double("class", split: ["Spaceship", "Certificate"]))
        nuke.certs = [cert, cert] # Need at least 2 to trigger the selection logic

        expect(UI).not_to receive(:confirm)

        # We need to mock Terminal::Table because filter_by_cert uses it
        allow(Terminal::Table).to receive(:new).and_return("table")

        nuke.filter_by_cert
      end

      it "honors skip_confirmation: true in run method" do
        values = {
          app_identifier: "tools.fastlane.app",
          type: "appstore",
          git_url: "https://github.com/fastlane/fastlane",
          username: "flapple@something.com",
          skip_confirmation: true
        }
        config = FastlaneCore::Configuration.create(Match::Options.available_options, values)

        nuke = Match::Nuke.new

        allow(nuke).to receive(:spaceship_login)
        allow(Match::Storage).to receive(:from_params).and_return(double("storage", download: nil, working_directory: "/tmp", clear_changes: nil))
        allow(Match::Encryption).to receive(:for_storage_mode).and_return(nil)
        allow(nuke).to receive(:prepare_list)
        allow(nuke).to receive(:filter_by_cert)
        allow(nuke).to receive(:print_tables)
        allow(nuke).to receive(:nuke_it_now!)

        # Mock certs/profiles/files to be non-empty
        nuke.certs = [double("cert")]
        nuke.profiles = [double("profile")]
        nuke.files = [double("file")]

        expect(UI).not_to receive(:confirm).with("Do you really want to nuke everything listed above?")

        nuke.run(config, type: config[:type])
      end

      it "honors skip_confirmation: true in spaceship_login" do
        nuke = Match::Nuke.new
        nuke.params = {
          skip_confirmation: true,
          username: "user",
          team_id: "team"
        }
        nuke.type = "enterprise"

        client = double("client", in_house?: true)
        allow(Spaceship::ConnectAPI).to receive(:client).and_return(client)
        allow(Spaceship::ConnectAPI).to receive(:login)

        expect(UI).not_to receive(:confirm)

        nuke.spaceship_login
      end
    end
  end
end
