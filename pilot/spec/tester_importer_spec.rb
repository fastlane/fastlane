require 'csv'

describe Pilot::TesterImporter do
  describe ".import_testers" do
    let(:fake_tester_importer) { Pilot::TesterImporter.new }

    context "when testers CSV file path is not given" do
      let(:fake_tester_manager) { double("tester manager") }
      let(:empty_input_options) { {} }

      before(:each) do
        fake_tester_importer.instance_variable_set(:@config, empty_input_options)
        allow(CSV).to receive(:foreach).and_return([])
        allow(Pilot::TesterManager).to receive(:new).and_return(fake_tester_manager)
        allow(fake_tester_importer).to receive(:start).with(empty_input_options)
      end

      it "raises an fatal exception with message" do
        expect(UI).to receive(:user_error!).with("Import file path is required")

        fake_tester_importer.import_testers(empty_input_options)
      end
    end

    context "when testers CSV file path is given" do
      let(:fake_tester_manager) { double("tester manager") }
      let(:fake_testers_file_path) { Tempfile.new("fake testers_file_path").path }
      let(:fake_input_options) do
        {
          testers_file_path: fake_testers_file_path
        }
      end

      before(:each) do
        fake_tester_importer.instance_variable_set(:@config, fake_input_options)
        allow(Pilot::TesterManager).to receive(:new).and_return(fake_tester_manager)
        allow(fake_tester_importer).to receive(:start).with(fake_input_options)
      end

      context "when No email found in CSV row" do
        let(:fake_row) { ["FirstName", "LastName", "group-1;group-2"] }

        before(:each) do
          allow(CSV).to receive(:foreach).with(fake_testers_file_path, "r").and_yield(fake_row)
        end

        it "prints an non-fatal error message and continue" do
          expect(UI).to receive(:error).with("No email found in row: #{fake_row}")
          expect(UI).to receive(:success).with("Successfully imported 0 testers from #{fake_testers_file_path}")

          fake_tester_importer.import_testers(fake_input_options)
        end
      end

      context "when invalid email found in CSV row" do
        let(:fake_row) { ["FirstName", "LastName", "invalid-email-address", "group-1;group-2"] }

        before(:each) do
          allow(CSV).to receive(:foreach).with(fake_testers_file_path, "r").and_yield(fake_row)
        end

        it "prints an non-fatal error message and continue" do
          expect(UI).to receive(:error).with("No email found in row: #{fake_row}")
          expect(UI).to receive(:success).with("Successfully imported 0 testers from #{fake_testers_file_path}")

          fake_tester_importer.import_testers(fake_input_options)
        end
      end

      context "when valid tester details found in CSV row" do
        let(:fake_email) { "valid@email.address" }
        let(:fake_row) { ["FirstName", "LastName", fake_email, "group-1;group-2"] }

        before(:each) do
          allow(CSV).to receive(:foreach).with(fake_testers_file_path, "r").and_yield(fake_row)
        end

        context "when tester manager succeeded to add a new tester" do
          before(:each) do
            expect(fake_tester_manager).to receive(:add_tester).with({
              first_name: "FirstName",
              last_name: "LastName",
              email: fake_email,
              groups: ["group-1", "group-2"],
              testers_file_path: fake_testers_file_path
            })
          end

          it "prints a success message for the added tester" do
            expect(UI).to receive(:success).with("Successfully imported 1 testers from #{fake_testers_file_path}")
            fake_tester_importer.import_testers(fake_input_options)
          end
        end

        context "when tester manager failed to add a new tester" do
          let(:fake_exception) { "fake exception" }

          before(:each) do
            expect(fake_tester_manager).to receive(:add_tester).with({
              first_name: "FirstName",
              last_name: "LastName",
              email: fake_email,
              groups: ["group-1", "group-2"],
              testers_file_path: fake_testers_file_path
            }).and_raise(fake_exception)
          end

          it "prints an non-fatal error message" do
            expect(UI).to receive(:error).with("Error adding tester #{fake_email}: #{fake_exception}")
            expect(UI).to receive(:success).with("Successfully imported 0 testers from #{fake_testers_file_path}")

            fake_tester_importer.import_testers(fake_input_options)
          end
        end
      end
    end
  end
end
