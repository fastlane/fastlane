describe Fastlane do
  describe Fastlane::Actions::SetupCircleCiAction do
    describe "#setup_output_paths" do
      before do
        stub_const("ENV", { "FL_OUTPUT_DIR" => "/dev/null" })
      end

      it "sets the SCAN_OUTPUT_DIRECTORY" do
        described_class.setup_output_paths(nil)
        expect(ENV["SCAN_OUTPUT_DIRECTORY"]).to eql("/dev/null/scan")
      end

      it "sets the GYM_OUTPUT_DIRECTORY" do
        described_class.setup_output_paths(nil)
        expect(ENV["GYM_OUTPUT_DIRECTORY"]).to eql("/dev/null/gym")
      end

      it "sets the FL_BUILDLOG_PATH" do
        described_class.setup_output_paths(nil)
        expect(ENV["FL_BUILDLOG_PATH"]).to eql("/dev/null/buildlogs")
      end
    end

    describe "#should_run" do
      context "when running on CI" do
        before do
          expect(Fastlane::Helper).to receive(:is_ci?).and_return(true)
        end

        it "returns true when :force is true" do
          expect(described_class.should_run?({ force: true })).to eql(true)
        end

        it "returns true when :force is false" do
          expect(described_class.should_run?({ force: false })).to eql(true)
        end
      end

      context "when not running on CI" do
        before do
          expect(Fastlane::Helper).to receive(:is_ci?).and_return(false)
        end

        it "returns false when :force is not set" do
          expect(described_class.should_run?({ force: false })).to eql(false)
        end

        it "returns true when :force is set" do
          expect(described_class.should_run?({ force: true })).to eql(true)
        end
      end
    end

    describe "#setup_keychain" do
      context "when MATCH_KEYCHAIN_NAME is set" do
        it "skips the setup process" do
          stub_const("ENV", { "MATCH_KEYCHAIN_NAME" => "anything" })
          expect(Fastlane::UI).to receive(:message).with("Skipping Keychain setup as a keychain was already specified")
          described_class.setup_keychain
        end
      end

      describe "Setting up the environment" do
        before do
          stub_const("ENV", {})
          allow(Fastlane::Actions::CreateKeychainAction).to receive(:run).and_return(nil)
        end

        it "sets the MATCH_KEYCHAIN_NAME env var" do
          described_class.setup_keychain
          expect(ENV["MATCH_KEYCHAIN_NAME"]).to eql("fastlane_tmp_keychain")
        end

        it "sets the MATCH_KEYCHAIN_PASSWORD env var" do
          described_class.setup_keychain
          expect(ENV["MATCH_KEYCHAIN_PASSWORD"]).to eql("")
        end

        it "sets the MATCH_READONLY env var" do
          described_class.setup_keychain
          expect(ENV["MATCH_READONLY"]).to eql("true")
        end
      end
    end
  end
end
