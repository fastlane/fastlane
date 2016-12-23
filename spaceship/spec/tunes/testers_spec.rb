describe Spaceship::Tunes::Tester do
  before { Spaceship::Tunes.login }

  let(:client) { Spaceship::AppSubmission.client }
  let(:app) { Spaceship::Application.all.first }

  it "raises an error when using the base class" do
    expect do
      Spaceship::Tunes::Tester.all
    end.to raise_error "You have to use a subclass: Internal or External"
  end

  describe "Receiving existing testers" do
    it "inspect works, by also fetching the parent's attributes" do
      t = Spaceship::Tunes::Tester::Internal.all.first
      expect(t.inspect).to include("Tunes::Tester")
      expect(t.inspect).to include("latest_install_app_id=")
    end

    it "Internal Testers" do
      testers = Spaceship::Tunes::Tester::Internal.all
      expect(testers.count).to eq(2)
      t = testers[1]
      expect(t.class).to eq(Spaceship::Tunes::Tester::Internal)

      expect(t.tester_id).to eq("1d167b89-13c5-4dd8-b988-7a6a0190f774")
      expect(t.email).to eq("felix@sunapps.net")
      expect(t.first_name).to eq("Felix")
      expect(t.last_name).to eq("Krause")
      expect(t.devices).to eq([{ "model" => "iPhone 6", "os" => "iOS", "osVersion" => "8.3", "name" => nil }])
    end

    it "External Testers" do
      testers = Spaceship::Tunes::Tester::External.all
      expect(testers.count).to eq(2)
      t = testers[0]
      expect(t.class).to eq(Spaceship::Tunes::Tester::External)

      expect(t.tester_id).to eq("1d167b89-13c5-4dd8-b988-7a6a0190faaa")
      expect(t.email).to eq("private@krausefx.com")
      expect(t.first_name).to eq("Detlef")
      expect(t.last_name).to eq("Müller")
      expect(t.devices).to eq([{ "model" => "iPhone 6", "os" => "iOS", "osVersion" => "8.3", "name" => nil }])
      expect(t.groups[0]["id"]).to eq("e031d021-4f0f-4c1e-8d8a-c3341a267986")
    end
  end

  describe "Receiving existing testers from an app" do
    it "Internal Testers" do
      testers = app.internal_testers
      expect(testers.count).to eq(1)
      t = testers.first
      expect(t.class).to eq(Spaceship::Tunes::Tester::Internal)

      expect(t.tester_id).to eq("1d167b89-13c5-4dd8-b988-7a6a0190f774")
      expect(t.email).to eq("felix@sunapps.net")
      expect(t.first_name).to eq("Felix")
      expect(t.last_name).to eq("Krause")
      expect(t.devices).to eq([])
    end
  end

  describe "Last Install information" do
    it "pre-fills this information correctly" do
      tester = Spaceship::Tunes::Tester::Internal.all[1]
      expect(tester.latest_install_app_id).to eq(794_902_327)
      expect(tester.latest_install_date).to eq(1_427_565_638_420)
      expect(tester.latest_installed_build_number).to eq("1")
      expect(tester.latest_installed_version_number).to eq("0.9.14")
    end
  end

  describe "Sandbox testers" do
    describe "listing" do
      it 'loads sandbox testers correctly' do
        testers = Spaceship::Tunes::SandboxTester.all
        expect(testers.count).to eq(1)
        t = testers[0]
        expect(t.class).to eq(Spaceship::Tunes::SandboxTester)

        expect(t.email).to eq("test@test.com")
        expect(t.first_name).to eq("Test")
        expect(t.last_name).to eq("McTestington")
        expect(t.country).to eq("GB")
      end
    end

    describe "creation" do
      before { allow(SecureRandom).to receive(:hex).and_return('so_secret') }
      it 'creates sandbox testers correctly' do
        t = Spaceship::Tunes::SandboxTester.create!(
          email: 'test2@test.com',
          password: 'Passwordtest1',
          country: 'US',
          first_name: 'Steve',
          last_name: 'Brule'
        )
        expect(t.class).to eq(Spaceship::Tunes::SandboxTester)

        expect(t.email).to eq("test2@test.com")
        expect(t.first_name).to eq("Steve")
        expect(t.last_name).to eq("Brule")
        expect(t.country).to eq("US")
      end
    end

    describe "deletion" do
      it 'deletes a user' do
        expect { Spaceship::Tunes::SandboxTester.delete!(['test@test.com']) }.not_to raise_error
      end

      it 'deletes all users' do
        expect { Spaceship::Tunes::SandboxTester.delete_all! }.not_to raise_error
      end
    end
  end

  # describe "invite testers to an existing app" do
  #   it "invite all users to an app" do
  #     app.add_all_testers!
  #   end
  # end
end
