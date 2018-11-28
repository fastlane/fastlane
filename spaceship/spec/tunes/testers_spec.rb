describe Spaceship::Tunes::SandboxTester do
  before { Spaceship::Tunes.login }

  let(:client) { Spaceship::AppSubmission.client }
  let(:app) { Spaceship::Application.all.first }

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
        expect { Spaceship::Tunes::SandboxTester.delete!(['test@test.com']) }.not_to(raise_error)
      end

      it 'deletes all users' do
        expect { Spaceship::Tunes::SandboxTester.delete_all! }.not_to(raise_error)
      end
    end
  end
end
