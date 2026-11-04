require 'csv'

describe Pilot::TesterExporter do
  describe ".export_testers" do
    let(:fake_tester_exporter) { Pilot::TesterExporter.new }
    let(:fake_tester_manager) { double("tester manager") }
    # Keep the Tempfile, not only its path: an unreferenced one is deleted when the GC finalises it. See fastlane#30184.
    let(:fake_testers_file) { Tempfile.new("fake testers_file_path") }
    let(:fake_testers_file_path) { fake_testers_file.path }
    let(:fake_apple_id) { "fake apple_id" }
    let(:fake_app_identifier) { "fake app_identifier" }
    let(:fake_input_options) do
      {
        testers_file_path: fake_testers_file_path,
        apple_id: fake_apple_id,
        app_identifier: fake_app_identifier
      }
    end

    before(:each) do
      fake_tester_exporter.instance_variable_set(:@config, fake_input_options)
      allow(Pilot::TesterManager).to receive(:new).and_return(fake_tester_manager)
      allow(fake_tester_exporter).to receive(:start).with(fake_input_options)
    end

    context "when able to find app using apple_id and app_identifier" do
      let(:fake_app) { "fake app" }

      before(:each) do
        allow(fake_app).to receive(:get_beta_testers).with(includes: "apps,betaGroups").and_return([])
        allow(fake_tester_exporter).to receive(:find_app).with(apple_id: fake_apple_id, app_identifier: fake_app_identifier).and_return(fake_app)
      end

      it "exports beta testers inside the correct file path" do
        expect(CSV).to receive(:open).with(fake_testers_file_path, "w")

        fake_tester_exporter.export_testers(fake_input_options)
      end

      it "shows a success message after export" do
        expect(UI).to receive(:success).with("Successfully exported CSV to #{fake_testers_file_path}")

        fake_tester_exporter.export_testers(fake_input_options)
      end
    end

    context "when testers have install data" do
      let(:fake_app) { "fake app" }
      let(:test_group) { Spaceship::ConnectAPI::BetaGroup.new("1", { name: "Test Group" }) }
      let(:installed_tester) do
        Spaceship::ConnectAPI::BetaTester.new("1", {
          firstName: "fake",
          lastName: "tester",
          email: "fake@tester.com",
          betaGroups: [test_group],
          state: "INSTALLED",
          appDevices: [{ "appBuildVersion" => "1.2.3 (1234)", "platform" => "IOS" }]
        })
      end
      let(:invited_tester) do
        Spaceship::ConnectAPI::BetaTester.new("2", {
          firstName: "new",
          lastName: "tester",
          email: "new@tester.com",
          betaGroups: [test_group],
          state: "INVITED"
        })
      end

      before(:each) do
        allow(fake_app).to receive(:get_beta_testers).with(includes: "apps,betaGroups").and_return([installed_tester, invited_tester])
        allow(fake_tester_exporter).to receive(:find_app).with(apple_id: fake_apple_id, app_identifier: fake_app_identifier).and_return(fake_app)
      end

      it "exports the installed version and build only for installed testers" do
        fake_tester_exporter.export_testers(fake_input_options)

        expect(CSV.read(fake_testers_file_path)).to eq([
                                                         ["First", "Last", "Email", "Groups", "Installed Version", "Install Date"],
                                                         ["fake", "tester", "fake@tester.com", "Test Group", "1.2.3 (1234)", "1234"],
                                                         ["new", "tester", "new@tester.com", "Test Group", nil, nil]
                                                       ])
      end
    end

    context "when installed testers have a bare build number" do
      let(:fake_app) { "fake app" }
      let(:test_group) { Spaceship::ConnectAPI::BetaGroup.new("1", { name: "Test Group" }) }
      let(:testers) do
        ["one", "two"].each_with_index.map do |name, index|
          Spaceship::ConnectAPI::BetaTester.new(index.to_s, {
            firstName: name,
            lastName: "tester",
            email: "#{name}@tester.com",
            betaGroups: [test_group],
            state: "INSTALLED",
            appDevices: [{ "appBuildVersion" => "1234", "platform" => "IOS" }]
          })
        end
      end

      before(:each) do
        allow(fake_app).to receive(:id).and_return("123456789")
        allow(fake_app).to receive(:get_beta_testers).with(includes: "apps,betaGroups").and_return(testers)
        allow(fake_tester_exporter).to receive(:find_app).with(apple_id: fake_apple_id, app_identifier: fake_app_identifier).and_return(fake_app)
      end

      it "looks up the version once and exports it for each tester" do
        expect(Spaceship::ConnectAPI::Build).to receive(:all).once.and_return([double("build", app_version: "1.2.3")])

        fake_tester_exporter.export_testers(fake_input_options)

        expected_rows = [
          ["First", "Last", "Email", "Groups", "Installed Version", "Install Date"],
          ["one", "tester", "one@tester.com", "Test Group", "1.2.3 (1234)", "1234"],
          ["two", "tester", "two@tester.com", "Test Group", "1.2.3 (1234)", "1234"]
        ]
        expect(CSV.read(fake_testers_file_path)).to eq(expected_rows)
      end
    end

    context "when failed to find app using apple_id and app_identifier" do
      let(:fake_app) { "fake app" }

      before(:each) do
        allow(fake_tester_exporter).to receive(:find_app).with(apple_id: fake_apple_id, app_identifier: fake_app_identifier).and_return(nil)
        allow(Spaceship::ConnectAPI::BetaTester).to receive(:all).with(includes: "apps,betaGroups").and_return([])
      end

      it "exports beta testers inside the correct file path" do
        expect(CSV).to receive(:open).with(fake_testers_file_path, "w")

        fake_tester_exporter.export_testers(fake_input_options)
      end

      it "shows a success message after export" do
        expect(UI).to receive(:success).with("Successfully exported CSV to #{fake_testers_file_path}")

        fake_tester_exporter.export_testers(fake_input_options)
      end
    end
  end

  describe ".find_app" do
    let(:fake_tester_exporter) { Pilot::TesterExporter.new }
    let(:fake_app) { "fake app" }

    context "when app_identifier is given" do
      let(:fake_app_identifier) { "fake app_identifier" }

      context "when able to find app using app_identifier" do
        before(:each) do
          allow(Spaceship::ConnectAPI::App).to receive(:find).with(fake_app_identifier).and_return(fake_app)
        end

        it "returns the app correctly" do
          received_app = fake_tester_exporter.find_app(app_identifier: fake_app_identifier)

          expect(received_app).to eq(fake_app)
        end
      end

      context "when failed to find app using app_identifier" do
        before(:each) do
          allow(Spaceship::ConnectAPI::App).to receive(:find).with(fake_app_identifier).and_return(nil)
        end

        it "raises an fatal exception with message" do
          expect(UI).to receive(:user_error!).with("Could not find an app by #{fake_app_identifier}")

          fake_tester_exporter.find_app(app_identifier: fake_app_identifier)
        end
      end
    end

    context "when app_identifier is not given but apple_id is given" do
      let(:fake_apple_id) { "fake apple_id" }

      context "when able to find app using apple_id" do
        before(:each) do
          allow(Spaceship::ConnectAPI::App).to receive(:get).with(app_id: fake_apple_id).and_return(fake_app)
        end

        it "returns the app correctly" do
          received_app = fake_tester_exporter.find_app(apple_id: fake_apple_id)

          expect(received_app).to eq(fake_app)
        end
      end

      context "when failed to find app using apple_id" do
        before(:each) do
          allow(Spaceship::ConnectAPI::App).to receive(:get).with(app_id: fake_apple_id).and_return(nil)
        end

        it "raises an fatal exception with message" do
          expect(UI).to receive(:user_error!).with("Could not find an app by #{fake_apple_id}")

          fake_tester_exporter.find_app(apple_id: fake_apple_id)
        end
      end
    end

    context "when app_identifier and apple_id both are not given" do
      it "raises an fatal exception with message" do
        expect(UI).to receive(:user_error!).with("You must include an `app_identifier` to `list_testers`")

        fake_tester_exporter.find_app
      end
    end
  end
end
