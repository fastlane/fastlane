describe Fastlane do
  describe Fastlane::Actions::SetupCiAction do
    describe "#run" do
      context "when it should run" do
        before do
          stub_const("ENV", { "CI" => "anything" })
          allow(Fastlane::Actions::CreateKeychainAction).to receive(:run).and_return(nil)
        end

        it "calls setup_keychain after setup_output_paths if :provider is set to circleci" do
          # Message is asserted in reverse order, hence output of setup_output_paths is expected last
          expect(Fastlane::UI).to receive(:message).with("Enabling match readonly mode.")
          expect(Fastlane::UI).to receive(:message).with("Creating temporary keychain: \"fastlane_tmp_keychain\".")
          expect(Fastlane::UI).to receive(:message).with("Skipping Log Path setup as FL_OUTPUT_DIR is unset")

          described_class.run(provider: "circleci")
        end

        it "calls setup_keychain if no provider is be detected" do
          expect(Fastlane::UI).to receive(:message).with("Enabling match readonly mode.")
          expect(Fastlane::UI).to receive(:message).with("Creating temporary keychain: \"fastlane_tmp_keychain\".")

          described_class.run(force: true)
        end
      end
    end

    describe "#should_run" do
      context "when running on CI" do
        before do
          expect(Fastlane::Helper).to receive(:ci?).and_return(true)
        end

        it "returns true when :force is true" do
          expect(described_class.should_run?(force: true)).to eql(true)
        end

        it "returns true when :force is false" do
          expect(described_class.should_run?(force: false)).to eql(true)
        end
      end

      context "when not running on CI" do
        before do
          expect(Fastlane::Helper).to receive(:ci?).and_return(false)
        end

        it "returns false when :force is not set" do
          expect(described_class.should_run?(force: false)).to eql(false)
        end

        it "returns true when :force is set" do
          expect(described_class.should_run?(force: true)).to eql(true)
        end
      end
    end

    describe "#detect_provider" do
      context "when running on CircleCI" do
        before do
          stub_const("ENV", { "CIRCLECI" => "anything" })
        end

        it "returns circleci when :provider is not set" do
          expect(described_class.detect_provider({})).to eql("circleci")
        end

        it "returns github when :provider is set to github" do
          expect(described_class.detect_provider(provider: "github")).to eql("github")
        end
      end

      context "when not running on CircleCI" do
        before do
          # Unset environment to ensure CIRCLECI is not set even if the test suite is run on CircleCI
          stub_const("ENV", {})
        end

        it "returns nil when :provider is not set" do
          expect(described_class.detect_provider({})).to eql(nil)
        end

        it "returns github when :provider is set to github" do
          expect(described_class.detect_provider(provider: "github")).to eql("github")
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

    describe "#setup_output_paths" do
      before do
        stub_const("ENV", { "FL_OUTPUT_DIR" => "/dev/null" })
      end

      it "sets the SCAN_OUTPUT_DIRECTORY" do
        described_class.setup_output_paths
        expect(ENV["SCAN_OUTPUT_DIRECTORY"]).to eql("/dev/null/scan")
      end

      it "sets the GYM_OUTPUT_DIRECTORY" do
        described_class.setup_output_paths
        expect(ENV["GYM_OUTPUT_DIRECTORY"]).to eql("/dev/null/gym")
      end

      it "sets the FL_BUILDLOG_PATH" do
        described_class.setup_output_paths
        expect(ENV["FL_BUILDLOG_PATH"]).to eql("/dev/null/buildlogs")
      end
    end
  end
end
