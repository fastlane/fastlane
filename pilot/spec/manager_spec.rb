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
          expect(fake_manager.instance_variable_get(:@config)).to eq(expected_options)
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

          expect(fake_manager.instance_variable_get(:@config)).to eq(options)
        end
      end

      context "when passing 'should_login' value as TRUE" do
        before(:each) do
          expect(fake_manager).to receive(:login)
        end

        it "sets the 'config' variable value and calls login" do
          options = {}
          fake_manager.start(options, should_login: true)

          expect(fake_manager.instance_variable_get(:@config)).to eq(options)
        end
      end

      context "when passing 'should_login' value as FALSE" do
        before(:each) do
          expect(fake_manager).not_to receive(:login)
        end

        it "sets the 'config' variable value and doesn't call login" do
          options = {}
          fake_manager.start(options, should_login: false)

          expect(fake_manager.instance_variable_get(:@config)).to eq(options)
        end
      end
    end

    describe "what happens on 'login'" do
      context "when using app store connect api token" do
        before(:each) do
          allow(Spaceship::ConnectAPI)
            .to receive(:token)
            .and_return(Spaceship::ConnectAPI::Token.from(filepath: fake_api_key_json_path))
        end

        it "uses the existing API token if found" do
          expect(Spaceship::ConnectAPI::Token).to receive(:from).with(hash: nil, filepath: nil).and_return(false)
          expect(UI).to receive(:message).with("Using existing authorization token for App Store Connect API")

          fake_manager.instance_variable_set(:@config, {})
          fake_manager.login
        end

        it "creates and sets new API token using config api_key and api_key_path" do
          expect(Spaceship::ConnectAPI::Token).to receive(:from).with(hash: "api_key", filepath: "api_key_path").and_return(true)
          expect(UI).to receive(:message).with("Creating authorization token for App Store Connect API")
          expect(Spaceship::ConnectAPI).to receive(:token=)

          options = {}
          options[:api_key] = "api_key"
          options[:api_key_path] = "api_key_path"

          fake_manager.instance_variable_set(:@config, options)
          fake_manager.login
        end
      end

      shared_examples "performing the spaceship login using username and password by pilot" do
        before(:each) do
          expect(fake_manager.config).to receive(:fetch).with(:username, force_ask: true)
          expect(UI).to receive(:message).with("Login to App Store Connect (username)")
          expect(Spaceship::ConnectAPI).to receive(:login)
          expect(UI).to receive(:message).with("Login successful")
        end

        it "performs the login using username and password" do
          fake_manager.login
        end
      end

      context "when using web session" do
        context "when username input param is given" do
          before(:each) do
            fake_manager.instance_variable_set(:@config, { username: "username" })
          end

          it_behaves_like "performing the spaceship login using username and password by pilot"
        end

        context "when username input param is not given but found apple_id in AppFile" do
          before(:each) do
            fake_manager.instance_variable_set(:@config, {})

            allow(CredentialsManager::AppfileConfig)
              .to receive(:try_fetch_value)
              .with(:apple_id)
              .and_return("username")
          end

          it_behaves_like "performing the spaceship login using username and password by pilot"
        end
      end
    end
  end
end
