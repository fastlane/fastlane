require 'csv'

describe Pilot::TesterExporter do
  describe ".export_testers" do
    let(:fake_tester_exporter) { Pilot::TesterExporter.new }
    let(:fake_tester_manager) { double("tester manager") }
    let(:fake_testers_file_path) { Tempfile.new("fake testers_file_path").path }
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
        allow(fake_app).to receive(:get_beta_testers).with(includes: "apps,betaTesterMetrics,betaGroups").and_return([])
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

    context "when failed to find app using apple_id and app_identifier" do
      let(:fake_app) { "fake app" }

      before(:each) do
        allow(fake_tester_exporter).to receive(:find_app).with(apple_id: fake_apple_id, app_identifier: fake_app_identifier).and_return(nil)
        allow(Spaceship::ConnectAPI::BetaTester).to receive(:all).with(includes: "apps,betaTesterMetrics,betaGroups").and_return([])
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
