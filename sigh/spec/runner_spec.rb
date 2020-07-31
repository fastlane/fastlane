describe Sigh do
  describe Sigh::Runner do
    before do
      ENV["DELIVER_USER"] = "test@fastlane.tools"
      ENV["DELIVER_PASSWORD"] = "123"
    end

    let(:fake_runner) { Sigh::Runner.new }
    let(:mock_base_client) { "fake api base client" }

    before(:each) do
      allow(mock_base_client).to receive(:login)
      allow(mock_base_client).to receive(:team_id).and_return('')

      allow(Spaceship::ConnectAPI::Provisioning::Client).to receive(:instance).and_return(mock_base_client)
    end

    describe "#run" do
    end

    describe "#profile_type" do
      profile_types = {
        "ios" => {
          Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_STORE => { in_house: false, options: { platform: "ios" } },
          Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_INHOUSE => { in_house: true, options: { platform: "ios" } },
          Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_ADHOC => { in_house: false, options: { platform: "ios", adhoc: true } },
          Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_DEVELOPMENT => { in_house: false, options: { platform: "ios", development: true } }
        },
        "tvos" => {
          Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_STORE => { in_house: false, options: { platform: "tvos" } },
          Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_INHOUSE => { in_house: true, options: { platform: "tvos" } },
          Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_ADHOC => { in_house: false, options: { platform: "tvos", adhoc: true } },
          Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_DEVELOPMENT => { in_house: false, options: { platform: "tvos", development: true } }
        },
        "macos" => {
          Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_STORE => { in_house: false, options: { platform: "macos" } },
          Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_DEVELOPMENT => { in_house: false, options: { platform: "macos", development: true } },
          Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_DIRECT => { in_house: false, options: { platform: "macos", developer_id: true } }
        },
        "catalyst" => {
          Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_STORE => { in_house: false, options: { platform: "catalyst" } },
          Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_DEVELOPMENT => { in_house: false, options: { platform: "catalyst", development: true } },
          Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_DIRECT => { in_house: false, options: { platform: "catalyst", developer_id: true } }
        }
      }

      # Iterates over platforms
      profile_types.each do |platform, test|
        context platform do
          # Creates test for each profile type in platform
          test.each do |type, test_options|
            it type do
              sigh_stub_spaceship_connect(inhouse: test_options[:in_house])

              Sigh.config = FastlaneCore::Configuration.create(Sigh::Options.available_options, test_options[:options])
              expect(fake_runner.profile_type).to eq(type)
            end
          end
        end
      end
    end

    describe "#fetch_profiles" do
    end

    describe "#profile_type_pretty_type" do
      profile_types = {
        Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_STORE => "AppStore",
        Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_INHOUSE => "InHouse",
        Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_ADHOC => "AdHoc",
        Spaceship::ConnectAPI::Profile::ProfileType::IOS_APP_DEVELOPMENT => "Development",
        Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_STORE => "AppStore",
        Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_INHOUSE => "InHouse",
        Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_ADHOC => "AdHoc",
        Spaceship::ConnectAPI::Profile::ProfileType::TVOS_APP_DEVELOPMENT => "Development",
        Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_STORE => "AppStore",
        Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_DEVELOPMENT => "Development",
        Spaceship::ConnectAPI::Profile::ProfileType::MAC_APP_DIRECT => "Direct",
        Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_STORE => "AppStore",
        Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_DEVELOPMENT => "Development",
        Spaceship::ConnectAPI::Profile::ProfileType::MAC_CATALYST_APP_DIRECT => "Direct"
      }

      # Creates test for each profile type
      profile_types.each do |type, pretty_type|
        it "#{type} - #{pretty_type}" do
          allow(fake_runner).to receive(:profile_type).and_return(type)
          expect(fake_runner.profile_type_pretty_type).to eq(pretty_type)
        end
      end
    end

    describe "#create_profile!" do
      context "successfully creates profile" do
        it "skips fetching of profiles" do
          sigh_stub_spaceship_connect(inhouse: false, create_profile_app_identifier: "com.krausefx.app", all_app_identifiers: ["com.krausefx.app"])

          allow(Spaceship).to receive(:client).and_return(mock_base_client)
          allow(mock_base_client).to receive(:in_house?).and_return(false)

          options = { app_identifier: "com.krausefx.app", skip_install: true, skip_certificate_verification: true, skip_fetch_profiles: true }
          Sigh.config = FastlaneCore::Configuration.create(Sigh::Options.available_options, options)

          profile = fake_runner.create_profile!

          expect(profile.name).to eq("com.krausefx.app AppStore")
          expect(profile.bundle_id.identifier).to eq("com.krausefx.app")
        end

        it "skips fetches profiles with no duplicate name" do
          sigh_stub_spaceship_connect(inhouse: false, create_profile_app_identifier: "com.krausefx.app", all_app_identifiers: ["com.krausefx.app"], profile_names: ["No dupe here"])

          allow(Spaceship).to receive(:client).and_return(mock_base_client)
          allow(mock_base_client).to receive(:in_house?).and_return(false)

          options = { app_identifier: "com.krausefx.app", skip_install: true, skip_certificate_verification: true, skip_fetch_profiles: true }
          Sigh.config = FastlaneCore::Configuration.create(Sigh::Options.available_options, options)

          profile = fake_runner.create_profile!

          expect(profile.name).to eq("com.krausefx.app AppStore")
          expect(profile.bundle_id.identifier).to eq("com.krausefx.app")
        end

        it "fetches profiles with duplicate name and appends timestamp" do
          sigh_stub_spaceship_connect(inhouse: false, create_profile_app_identifier: "com.krausefx.app", all_app_identifiers: ["com.krausefx.app"], profile_names: ["com.krausefx.app AppStore"])

          expect(Time).to receive(:now).and_return("1234")

          allow(Spaceship).to receive(:client).and_return(mock_base_client)
          allow(mock_base_client).to receive(:in_house?).and_return(false)

          options = { app_identifier: "com.krausefx.app", skip_install: true, skip_certificate_verification: true, skip_fetch_profiles: false }
          Sigh.config = FastlaneCore::Configuration.create(Sigh::Options.available_options, options)

          profile = fake_runner.create_profile!

          expect(profile.name).to eq("com.krausefx.app AppStore 1234")
          expect(profile.bundle_id.identifier).to eq("com.krausefx.app")
        end
      end

      context "raises error" do
        it "when cannot find bundle id" do
          sigh_stub_spaceship_connect(inhouse: false, all_app_identifiers: [])

          allow(Spaceship).to receive(:client).and_return(mock_base_client)
          allow(mock_base_client).to receive(:in_house?).and_return(false)

          options = { app_identifier: "com.krausefx.app", skip_install: true, skip_certificate_verification: true, skip_fetch_profiles: true }
          Sigh.config = FastlaneCore::Configuration.create(Sigh::Options.available_options, options)

          expect do
            fake_runner.create_profile!
          end.to raise_error("Could not find App with App Identifier 'com.krausefx.app'")
        end

        it "when name already taken" do
          sigh_stub_spaceship_connect(inhouse: false, all_app_identifiers: ["com.krausefx.app"], profile_names: ["com.krausefx.app AppStore"])

          allow(Spaceship).to receive(:client).and_return(mock_base_client)
          allow(mock_base_client).to receive(:in_house?).and_return(false)

          options = { app_identifier: "com.krausefx.app", skip_install: true, skip_certificate_verification: true, skip_fetch_profiles: false, fail_on_name_taken: true }
          Sigh.config = FastlaneCore::Configuration.create(Sigh::Options.available_options, options)

          expect do
            fake_runner.create_profile!
          end.to raise_error("The name 'com.krausefx.app AppStore' is already taken, and fail_on_name_taken is true")
        end
      end
    end

    describe "#download_profile" do
    end
  end
end
