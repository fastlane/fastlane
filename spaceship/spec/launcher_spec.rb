describe Spaceship do
  describe Spaceship::Launcher do
    let(:username) { 'spaceship@krausefx.com' }
    let(:password) { 'so_secret' }
    let(:spaceship1) { Spaceship::Launcher.new }
    let(:spaceship2) { Spaceship::Launcher.new }

    before do
      spaceship1.login(username, password)
      spaceship2.login(username, password)
    end

    it 'should have 2 separate spaceships' do
      expect(spaceship1).to_not(eq(spaceship2))
    end

    it '#select_team' do
      expect(spaceship1.select_team).to eq("XXXXXXXXXX")
    end

    it "may have different teams" do
      team_id = "ABCDEF"
      spaceship1.client.team_id = team_id

      expect(spaceship1.client.team_id).to eq(team_id) # custom
      expect(spaceship2.client.team_id).to eq("XXXXXXXXXX") # default
    end

    it "Device" do
      expect(spaceship1.device.all.count).to eq(4)
    end

    it "DeviceDisabled" do
      expect(spaceship1.device.all(include_disabled: true).count).to eq(6)
    end

    it "Certificate" do
      expect(spaceship1.certificate.all.count).to eq(3)
    end

    it "ProvisioningProfile" do
      expect(spaceship1.provisioning_profile.all.count).to eq(7)
    end

    it "App" do
      expect(spaceship1.app.all.count).to eq(5)
    end

    context "With an uninitialized environment" do
      before do
        Spaceship::App.set_client(nil)
        Spaceship::AppGroup.set_client(nil)
        Spaceship::Device.set_client(nil)
        Spaceship::Certificate.set_client(nil)
        Spaceship::ProvisioningProfile.set_client(nil)
      end
      it "shouldn't fail if provisioning_profile is invoked before app and device" do
        clean_launcher = Spaceship::Launcher.new
        clean_launcher.login(username, password)
        expect(clean_launcher.provisioning_profile.all.count).to eq(7)
      end

      it "shouldn't fail if trying to create new apns_certificate before app is invoked" do
        clean_launcher = Spaceship::Launcher.new
        clean_launcher.login(username, password)

        expect(clean_launcher.client).to receive(:create_certificate!).with('BKLRAVXMGM', /BEGIN CERTIFICATE REQUEST/, 'B7JBD8LHAA', false) do
          JSON.parse(PortalStubbing.adp_read_fixture_file('certificateCreate.certRequest.json'))
        end

        csr, pkey = Spaceship::Portal::Certificate.create_certificate_signing_request
        expect do
          clean_launcher.certificate.development_push.create!(csr: csr, bundle_id: 'net.sunapps.151')
        end.to_not(raise_error)
      end
    end
  end
end
