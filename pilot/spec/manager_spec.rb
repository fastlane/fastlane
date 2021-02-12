describe Pilot do
  describe Pilot::Manager do
    let(:fake_manager) { Pilot::Manager.new }

    let(:fake_api_key_json_path) do
      "./spaceship/spec/connect_api/fixtures/asc_key.json"
    end
    let(:fake_api_key) do
      JSON.parse(File.read(fake_api_key_json_path), { symbolize_names: true })
    end

    context "#login" do
      it "token auth" do
        fake_manager.instance_variable_set(:@config, { api_key: fake_api_key })

        expect(Spaceship::ConnectAPI).to receive(:token=)
        fake_manager.login
      end

      it "web session auth" do
        fake_manager.instance_variable_set(:@config, { username: "username" })

        expect(Spaceship::ConnectAPI).to receive(:login)
        fake_manager.login
      end
    end
  end
end
