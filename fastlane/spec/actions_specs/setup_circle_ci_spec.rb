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

    describe "Setup CircleCi Integration" do
      let(:tmp_keychain_name) { "fastlane_tmp_keychain" }
      it "doesn't work outside CI" do
        stub_const("ENV", {})

        expect(UI).to receive(:message).with("Not running on CI, skipping `setup_circle_ci`")

        Fastlane::FastFile.new.parse("lane :test do
          setup_circle_ci
        end").runner.execute(:test)

        expect(ENV["MATCH_KEYCHAIN_NAME"]).to be_nil
        expect(ENV["MATCH_KEYCHAIN_PASSWORD"]).to be_nil
        expect(ENV["MATCH_READONLY"]).to be_nil
      end

      it "works when forced" do
        stub_const("ENV", {})

        Fastlane::FastFile.new.parse("lane :test do
          setup_circle_ci(
            force: true
          )
        end").runner.execute(:test)

        expect(ENV["MATCH_KEYCHAIN_NAME"]).to eq(tmp_keychain_name)
        expect(ENV["MATCH_KEYCHAIN_PASSWORD"]).to eq("")
        expect(ENV["MATCH_READONLY"]).to eq("true")
      end

      it "works inside CI" do
        expect(Fastlane::Actions::CreateKeychainAction).to receive(:run).with(
          {
            name: tmp_keychain_name,
            default_keychain: true,
            unlock: true,
            timeout: 3600,
            lock_when_sleeps: true,
            password: ""
          }
        )

        stub_const("ENV", { "FL_SETUP_CIRCLECI_FORCE" => "true" })

        Fastlane::FastFile.new.parse("lane :test do
          setup_circle_ci
        end").runner.execute(:test)

        expect(ENV["MATCH_KEYCHAIN_NAME"]).to eq(tmp_keychain_name)
        expect(ENV["MATCH_KEYCHAIN_PASSWORD"]).to eq("")
        expect(ENV["MATCH_READONLY"]).to eq("true")
      end
    end
  end
end
