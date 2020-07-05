describe Fastlane do
  describe Fastlane::FastFile do
    describe "Setup Travis Integration" do
      let(:tmp_keychain_name) { "fastlane_tmp_keychain" }
      is_macos_env = RUBY_PLATFORM.downcase.include?("darwin")
      expected_test_result = is_macos_env ? 'works on MacOS Environment' : 'skips outside MacOS Environment'

      def check_keychain_nil
        expect(ENV["MATCH_KEYCHAIN_NAME"]).to be_nil
        expect(ENV["MATCH_KEYCHAIN_PASSWORD"]).to be_nil
        expect(ENV["MATCH_READONLY"]).to be_nil
      end

      def check_keychain_created
        expect(ENV["MATCH_KEYCHAIN_NAME"]).to eq(tmp_keychain_name)
        expect(ENV["MATCH_KEYCHAIN_PASSWORD"]).to eq("")
        expect(ENV["MATCH_READONLY"]).to eq("true")
      end

      it "doesn't work outside CI" do
        stub_const("ENV", {})

        expect(UI).to receive(:message).with("Not running on CI, skipping CI setup")

        Fastlane::FastFile.new.parse("lane :test do
          setup_travis
        end").runner.execute(:test)

        check_keychain_nil
      end

      it "#{expected_test_result} when forced" do
        stub_const("ENV", {})

        Fastlane::FastFile.new.parse("lane :test do
          setup_travis(
            force: true
          )
        end").runner.execute(:test)

        if is_macos_env
          check_keychain_created
        else
          check_keychain_nil
        end
      end

      it "#{expected_test_result} inside CI" do
        if is_macos_env
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
        end

        stub_const("ENV", { "TRAVIS" => "true" })

        Fastlane::FastFile.new.parse("lane :test do
          setup_travis
        end").runner.execute(:test)

        if is_macos_env
          check_keychain_created
        else
          check_keychain_nil
        end
      end
    end
  end
end
