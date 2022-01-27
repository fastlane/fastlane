describe Pilot do
  describe Pilot::Manager do
    let(:fake_manager) { Pilot::Manager.new }

    let(:fake_api_key_json_path) do
      "./spaceship/spec/connect_api/fixtures/asc_key.json"
    end
    let(:fake_api_key) do
      JSON.parse(File.read(fake_api_key_json_path), { symbolize_names: true })
    end

    let(:fake_app_id) { "fake app_id" }
    let(:fake_app) { "fake app" }
    let(:fake_app_identifier) { "fake app_identifier" }
    let(:fake_ipa) { "fake ipa" }
    let(:fake_pkg) { "fake pkg" }

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
        context "when input options has no 'api_key' or 'api_key_path' param" do
          before(:each) do
            expect(fake_manager).not_to receive(:login)
          end

          it "sets the 'config' variable value and doesn't call login" do
            options = {}
            fake_manager.start(options, should_login: false)

            expect(fake_manager.instance_variable_get(:@config)).to eq(options)
          end
        end

        context "when input options has 'api_key' param" do
          before(:each) do
            expect(fake_manager).to receive(:login)
          end

          it "sets the 'config' variable value and calls login for appstore connect api token" do
            options = { api_key: "fake_api_key" }
            fake_manager.start(options, should_login: false)

            expect(fake_manager.instance_variable_get(:@config)).to eq(options)
          end
        end

        context "when input options has 'api_key_path' param" do
          before(:each) do
            expect(fake_manager).to receive(:login)
          end

          it "sets the 'config' variable value and calls login for appstore connect api token" do
            options = { api_key_path: "fake api_key_path" }
            fake_manager.start(options, should_login: false)

            expect(fake_manager.instance_variable_get(:@config)).to eq(options)
          end
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

    describe "what happens on fetching the 'app'" do
      context "when 'app_id' variable is already set" do
        before(:each) do
          allow(Spaceship::ConnectAPI::App)
            .to receive(:get)
            .with({ app_id: fake_app_id })
            .and_return(fake_app)

          fake_manager.instance_variable_set(:@app_id, fake_app_id)
        end

        it "uses the existing 'app_id' value" do
          app_result = fake_manager.app

          expect(fake_manager.instance_variable_get(:@app_id)).to eq(fake_app_id)
          expect(app_result).to eq(fake_app)
        end
      end

      context "when 'app_id' variable is not set" do
        before(:each) do
          allow(fake_manager)
            .to receive(:fetch_app_id)
            .and_return(fake_app_id)

          allow(Spaceship::ConnectAPI::App)
            .to receive(:get)
            .with({ app_id: fake_app_id })
            .and_return(fake_app)

          expect(fake_manager).to receive(:fetch_app_id)
        end

        it "tries to find the app ID automatically" do
          app_result = fake_manager.app

          expect(app_result).to eq(fake_app)
        end
      end

      context "when 'app' variable is not set" do
        context "when Spaceship retuns a valid 'app' object" do
          before(:each) do
            allow(fake_manager)
              .to receive(:fetch_app_id)
              .and_return(fake_app_id)

            allow(Spaceship::ConnectAPI::App)
              .to receive(:get)
              .with({ app_id: fake_app_id })
              .and_return(fake_app)

            expect(fake_manager).to receive(:fetch_app_id)
          end

          it "retuns the Spaceship app object" do
            app_result = fake_manager.app

            expect(app_result).to eq(fake_app)
          end
        end

        context "when Spaceship failed to return a valid 'app' object" do
          before(:each) do
            fake_manager.instance_variable_set(:@config, { apple_id: fake_app_id })

            allow(fake_manager)
              .to receive(:fetch_app_id)
              .and_return(fake_app_id)

            allow(Spaceship::ConnectAPI::App)
              .to receive(:get)
              .with({ app_id: fake_app_id })
              .and_return(nil)

            expect(fake_manager).to receive(:fetch_app_id)
          end

          it "raises the 'Could not find app' exception" do
            expect(UI).to receive(:user_error!).with("Could not find app with #{fake_app_id}")

            fake_manager.app
          end
        end
      end
    end

    describe "what happens on fetching the 'app_id'" do
      context "when 'app_id' variable is already set" do
        before(:each) do
          fake_manager.instance_variable_set(:@app_id, fake_app_id)
        end

        it "uses the existing 'app_id' value" do
          fetch_app_id_result = fake_manager.fetch_app_id

          expect(fake_manager.instance_variable_get(:@app_id)).to eq(fake_app_id)
          expect(fetch_app_id_result).to eq(fake_app_id)
        end
      end

      context "when 'app_id' variable is not set but config has apple_id" do
        before(:each) do
          fake_manager.instance_variable_set(:@config, { apple_id: fake_app_id })
        end

        it "uses the config apple_id for 'app_id' value" do
          fetch_app_id_result = fake_manager.fetch_app_id

          expect(fake_manager.instance_variable_get(:@app_id)).to eq(fake_app_id)
          expect(fetch_app_id_result).to eq(fake_app_id)
        end
      end

      context "when 'app_id' variable is not set, config does not has apple_id and failed to find app_identifier" do
        before(:each) do
          fake_manager.instance_variable_set(:@config, { apple_id: nil })

          allow(fake_manager)
            .to receive(:fetch_app_identifier)
            .and_return(nil)
        end

        it "asks user to enter the app ID manually" do
          expect(UI)
            .to receive(:input)
            .with("Could not automatically find the app ID, please enter it here (e.g. 956814360): ")
            .and_return(fake_app_id)

          fetch_app_id_result = fake_manager.fetch_app_id

          expect(fetch_app_id_result).to eq(fake_app_id)
        end
      end

      context "when 'app_id' variable is not set, config does not has apple_id but found the app_identifier" do
        let(:fake_username) { "fake username" }

        before(:each) do
          fake_manager.instance_variable_set(:@config, { apple_id: nil })

          allow(fake_manager)
            .to receive(:fetch_app_identifier)
            .and_return(fake_app_identifier)
        end

        context "when Spaceship failed to find the 'app' object using the app_identifier" do
          before(:each) do
            RSpec::Mocks.configuration.allow_message_expectations_on_nil = true
            fake_manager.instance_variable_set(:@config, { username: fake_username })

            allow(Spaceship::ConnectAPI::App)
              .to receive(:find)
              .with(fake_app_identifier)
              .and_return(nil)
          end

          after(:each) do
            RSpec::Mocks.configuration.allow_message_expectations_on_nil = false
          end

          it "raises the 'Could not find app' exception" do
            allow(nil).to receive(:id).and_return(fake_app_id)
            expect(UI).to receive(:user_error!).with("Couldn't find app '#{fake_app_identifier}' on the account of '#{fake_username}' on App Store Connect")

            fake_manager.fetch_app_id
          end
        end

        context "when Spaceship found the 'app' object using the app_identifier" do
          before(:each) do
            allow(Spaceship::ConnectAPI::App)
              .to receive(:find)
              .with(fake_app_identifier)
              .and_return(OpenStruct.new(id: fake_app_id))
          end

          it "uses the Spaceship app id for 'app_id' value" do
            fetch_app_id_result = fake_manager.fetch_app_id

            expect(fake_manager.instance_variable_get(:@app_id)).to eq(fake_app_id)
            expect(fetch_app_id_result).to eq(fake_app_id)
          end
        end
      end
    end

    describe "what happens on fetching the 'app_identifier'" do
      before(:each) do
        expect(UI).to receive(:verbose).with("App identifier (#{fake_app_identifier})")
      end

      context "when config has 'app_identifier' variable" do
        before(:each) do
          fake_manager.instance_variable_set(:@config, { app_identifier: fake_app_identifier })
        end

        it "uses the config 'app_identifier' value" do
          fetch_app_identifier_result = fake_manager.fetch_app_identifier

          expect(fetch_app_identifier_result).to eq(fake_app_identifier)
        end
      end

      context "when config does not has 'app_identifier' but has 'ipa' path variable" do
        before(:each) do
          fake_manager.instance_variable_set(:@config, { ipa: fake_ipa })

          allow(FastlaneCore::IpaFileAnalyser)
            .to receive(:fetch_app_identifier)
            .with(fake_ipa)
            .and_return(fake_app_identifier)
        end

        it "uses the FastlaneCore::IpaFileAnalyser with 'ipa' path to find the 'app_identifier' value" do
          fetch_app_identifier_result = fake_manager.fetch_app_identifier

          expect(fetch_app_identifier_result).to eq(fake_app_identifier)
        end
      end

      context "when config does not has 'app_identifier' but has 'pkg' path variable" do
        before(:each) do
          fake_manager.instance_variable_set(:@config, { pkg: fake_pkg })

          allow(FastlaneCore::PkgFileAnalyser)
            .to receive(:fetch_app_identifier)
            .with(fake_pkg)
            .and_return(fake_app_identifier)
        end

        it "uses the FastlaneCore::PkgFileAnalyser with 'pkg' path to find the 'app_identifier' value" do
          fetch_app_identifier_result = fake_manager.fetch_app_identifier

          expect(fetch_app_identifier_result).to eq(fake_app_identifier)
        end
      end

      context "when FastlaneCore::IpaFileAnalyser failed to fetch the 'app_identifier' variable" do
        before(:each) do
          fake_manager.instance_variable_set(:@config, { ipa: fake_ipa })

          allow(FastlaneCore::IpaFileAnalyser)
            .to receive(:fetch_app_identifier)
            .with(fake_ipa)
            .and_return(nil)
        end

        it "asks user to enter the app's bundle identifier manually" do
          expect(UI).to receive(:input).with("Please enter the app's bundle identifier: ").and_return(fake_app_identifier)

          fetch_app_identifier_result = fake_manager.fetch_app_identifier

          expect(fetch_app_identifier_result).to eq(fake_app_identifier)
        end
      end
    end

    describe "what happens on fetching the 'app_platform'" do
      context "when config has 'app_platform' variable" do
        context "ios" do
          let(:fake_app_platform) { "ios" }

          before(:each) do
            expect(UI).to receive(:verbose).with("App Platform (#{fake_app_platform})")
            fake_manager.instance_variable_set(:@config, { app_platform: fake_app_platform })
          end

          it "uses the config 'app_platform' value" do
            fetch_app_platform_result = fake_manager.fetch_app_platform

            expect(fetch_app_platform_result).to eq(fake_app_platform)
          end
        end

        context "osx" do
          let(:fake_app_platform) { "osx" }

          before(:each) do
            expect(UI).to receive(:verbose).with("App Platform (#{fake_app_platform})")
            fake_manager.instance_variable_set(:@config, { app_platform: fake_app_platform })
          end

          it "uses the config 'app_platform' value" do
            fetch_app_platform_result = fake_manager.fetch_app_platform

            expect(fetch_app_platform_result).to eq(fake_app_platform)
          end
        end
      end

      context "when config does not have 'app_platform'" do
        context "but has 'ipa' path variable" do
          let(:fake_app_platform) { "ios" }

          before(:each) do
            expect(UI).to receive(:verbose).with("App Platform (#{fake_app_platform})")
            fake_manager.instance_variable_set(:@config, { ipa: fake_ipa })

            expect(FastlaneCore::IpaFileAnalyser)
              .to receive(:fetch_app_platform)
              .with(fake_ipa)
              .and_return(fake_app_platform)
          end

          it "uses the FastlaneCore::IpaFileAnalyser with 'ipa' path to find the 'app_platform' value" do
            fetch_app_platform_result = fake_manager.fetch_app_platform

            expect(fetch_app_platform_result).to eq(fake_app_platform)
          end
        end

        context "but has 'pkg' path variable" do
          let(:fake_app_platform) { "osx" }

          before(:each) do
            expect(UI).to receive(:verbose).with("App Platform (#{fake_app_platform})")
            fake_manager.instance_variable_set(:@config, { pkg: fake_pkg })

            expect(FastlaneCore::PkgFileAnalyser)
              .to receive(:fetch_app_platform)
              .with(fake_pkg)
              .and_return(fake_app_platform)
          end

          it "uses the FastlaneCore::PkgFileAnalyser with 'pkg' path to find the 'app_platform' value" do
            fetch_app_platform_result = fake_manager.fetch_app_platform

            expect(fetch_app_platform_result).to eq(fake_app_platform)
          end
        end
      end

      context "when FastlaneCore::IpaFileAnalyser failed to fetch the 'app_platform' variable" do
        context "ios" do
          let(:fake_app_platform) { "ios" }

          before(:each) do
            expect(UI).to receive(:verbose).with("App Platform (#{fake_app_platform})")
            fake_manager.instance_variable_set(:@config, { ipa: fake_ipa })

            allow(FastlaneCore::IpaFileAnalyser)
              .to receive(:fetch_app_platform)
              .with(fake_ipa)
              .and_return(nil)
          end

          it "asks user to enter the app's platform manually" do
            expect(UI).to receive(:input).with("Please enter the app's platform (appletvos, ios, osx): ").and_return(fake_app_platform)

            fetch_app_platform_result = fake_manager.fetch_app_platform

            expect(fetch_app_platform_result).to eq(fake_app_platform)
          end
        end

        context "osx" do
          let(:fake_app_platform) { "osx" }

          before(:each) do
            expect(UI).to receive(:verbose).with("App Platform (#{fake_app_platform})")
            fake_manager.instance_variable_set(:@config, { pkg: fake_pkg })

            allow(FastlaneCore::PkgFileAnalyser)
              .to receive(:fetch_app_platform)
              .with(fake_pkg)
              .and_return(nil)
          end

          it "asks user to enter the app's platform manually" do
            expect(UI).to receive(:input).with("Please enter the app's platform (appletvos, ios, osx): ").and_return(fake_app_platform)

            fetch_app_platform_result = fake_manager.fetch_app_platform

            expect(fetch_app_platform_result).to eq(fake_app_platform)
          end
        end
      end

      context "when FastlaneCore::IpaFileAnalyser failed to fetch the 'app_platform' variable and its not required to enter manually" do
        context "ios" do
          let(:fake_app_platform) { "ios" }

          before(:each) do
            expect(UI).not_to receive(:verbose).with("App Platform (#{fake_app_platform})")
            fake_manager.instance_variable_set(:@config, { ipa: fake_ipa })

            allow(FastlaneCore::IpaFileAnalyser)
              .to receive(:fetch_app_platform)
              .with(fake_ipa)
              .and_return(nil)
          end

          it "does not ask user to enter the app's platform manually" do
            expect(UI).not_to receive(:input).with("Please enter the app's platform (appletvos, ios, osx): ")

            fetch_app_platform_result = fake_manager.fetch_app_platform(required: false)

            expect(fetch_app_platform_result).to eq(nil)
          end
        end
      end

      context "when user entered an invalid 'app_platform' manually" do
        let(:invalid_app_platform) { "invalid platform" }

        before(:each) do
          expect(UI).to receive(:verbose).with("App Platform (#{invalid_app_platform})")
          fake_manager.instance_variable_set(:@config, { ipa: fake_ipa })

          allow(FastlaneCore::IpaFileAnalyser)
            .to receive(:fetch_app_platform)
            .with(fake_ipa)
            .and_return(nil)

          allow(UI)
            .to receive(:input)
            .with("Please enter the app's platform (appletvos, ios, osx): ")
            .and_return(invalid_app_platform)
        end

        it "raises the 'invalid platform' exception" do
          expect(UI).to receive(:user_error!).with("App Platform must be ios, appletvos, or osx")

          fake_manager.fetch_app_platform
        end
      end
    end

    describe 'direct token text support' do
      describe '#login' do
        context 'with valid token' do
          api_token_text = 'Token.Text.JWT_content'
          in_house = false
          api_token = { in_house: in_house, token_text: api_token_text }

          let(:mock_token) { Spaceship::ConnectAPI::Token.from(filepath: fake_api_key_json_path) }

          before(:each) do
            allow(Spaceship::ConnectAPI::Token).to receive(:from_token).and_return(mock_token)
            allow(Spaceship::ConnectAPI).to receive(:token=)

            fake_manager.instance_variable_set(:@config, { api_token: api_token })
            fake_manager.login
          end

          it 'creates token' do
            expect(Spaceship::ConnectAPI::Token).to have_received(:from_token).with(api_token)
          end

          it 'assigns token' do
            expect(Spaceship::ConnectAPI).to have_received(:token=).with(mock_token)
          end
        end
      end
    end
  end
end
