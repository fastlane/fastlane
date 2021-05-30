describe Pilot do
  describe Pilot::Manager do
    let(:fake_manager) { Pilot::Manager.new }

    let(:fake_api_key_json_path) do
      "./spaceship/spec/connect_api/fixtures/asc_key.json"
    end
    let(:fake_api_key) do
      JSON.parse(File.read(fake_api_key_json_path), { symbolize_names: true })
    end

    describe "what happens on 'start'" do
      context "when 'config' variable is already set" do
        before(:each) do
          fake_manager.instance_variable_set(:@config, { api_key: fake_api_key })
        end

        it "doesn't override the 'config' variable value" do
          options = {}
          fake_manager.start(options)

          expected_options = { api_key: fake_api_key }
          expect(fake_manager.instance_variable_get(:@config)).to eql(expected_options)
        end

        it "doesn't call login" do
          expect(fake_manager).not_to receive(:login)

          options = {}
          fake_manager.start(options)
        end
      end

      context "when using the default 'should_login' value" do
        before(:each) do
          expect(fake_manager).to receive(:login)
        end

        it "sets the 'config' variable value and calls login" do
          options = {}
          fake_manager.start(options)

          expect(fake_manager.instance_variable_get(:@config)).to eql(options)
        end
      end

      context "when passing 'should_login' value as TRUE" do
        before(:each) do
          expect(fake_manager).to receive(:login)
        end

        it "sets the 'config' variable value and calls login" do
          options = {}
          fake_manager.start(options, should_login: true)

          expect(fake_manager.instance_variable_get(:@config)).to eql(options)
        end
      end

      context "when passing 'should_login' value as FALSE" do
        before(:each) do
          expect(fake_manager).not_to receive(:login)
        end

        it "sets the 'config' variable value and doesn't call login" do
          options = {}
          fake_manager.start(options, should_login: false)

          expect(fake_manager.instance_variable_get(:@config)).to eql(options)
        end
      end
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
