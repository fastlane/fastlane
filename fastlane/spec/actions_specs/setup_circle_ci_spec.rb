describe Fastlane do
  describe Fastlane::Actions::SetupCircleCiAction do
    describe "Setup CircleCi Integration" do
      let(:tmp_keychain_name) { "fastlane_tmp_keychain" }

      def check_keychain_nil
        expect(ENV.fetch("MATCH_KEYCHAIN_NAME", nil)).to be_nil
        expect(ENV.fetch("MATCH_KEYCHAIN_PASSWORD", nil)).to be_nil
        expect(ENV.fetch("MATCH_READONLY", nil)).to be_nil
      end

      def check_keychain_created
        expect(ENV.fetch("MATCH_KEYCHAIN_NAME", nil)).to eq(tmp_keychain_name)
        expect(ENV.fetch("MATCH_KEYCHAIN_PASSWORD", nil)).to eq("")
        expect(ENV.fetch("MATCH_READONLY", nil)).to eq("true")
      end

      it "doesn't work outside CI" do
        allow(FastlaneCore::Helper).to receive(:mac?).and_return(true)
        stub_const("ENV", {})

        expect(UI).to receive(:message).with("Not running on CI, skipping CI setup")

        Fastlane::FastFile.new.parse("lane :test do
          setup_circle_ci
        end").runner.execute(:test)

        check_keychain_nil
      end

      it "skips outside macOS CI agent" do
        allow(FastlaneCore::Helper).to receive(:mac?).and_return(false)
        stub_const("ENV", { "FL_SETUP_CIRCLECI_FORCE" => "true" })

        expect(UI).to receive(:message).with("Skipping Log Path setup as FL_OUTPUT_DIR is unset")
        expect(UI).to receive(:message).with("Skipping Keychain setup on non-macOS CI Agent")

        Fastlane::FastFile.new.parse("lane :test do
          setup_circle_ci
        end").runner.execute(:test)

        check_keychain_nil
      end

      it "works on MacOS Environment when forced" do
        allow(FastlaneCore::Helper).to receive(:mac?).and_return(true)
        stub_const("ENV", {})

        Fastlane::FastFile.new.parse("lane :test do
          setup_circle_ci(
            force: true
          )
        end").runner.execute(:test)

        check_keychain_created
      end

      it "works on MacOS Environment inside CI" do
        allow(FastlaneCore::Helper).to receive(:mac?).and_return(true)
        expect(Fastlane::Actions::CreateKeychainAction).to receive(:run).with(
          {
              name: tmp_keychain_name,
              default_keychain: true,
              unlock: true,
              timeout: 3600,
              lock_when_sleeps: true,
              password: "",
              add_to_search_list: true
          }
        )

        stub_const("ENV", { "FL_SETUP_CIRCLECI_FORCE" => "true" })

        Fastlane::FastFile.new.parse("lane :test do
          setup_circle_ci
        end").runner.execute(:test)

        check_keychain_created
      end
    end
  end
end
