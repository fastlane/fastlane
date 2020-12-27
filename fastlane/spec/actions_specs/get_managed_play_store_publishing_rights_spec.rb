describe Fastlane do
  describe Fastlane::FastFile do
    describe "get_managed_play_store_publishing_rights" do
      let(:json_key_path) { File.expand_path("./fastlane/spec/fixtures/google_play/google_play.json") }
      let(:json_key_data) { File.open(json_key_path, 'rb').read }
      let(:json_key_client_email) { JSON.parse(json_key_data)['client_email'] }

      describe "without options" do
        it "could not find file" do
          # Ensures that people's local environment variable doesn't interfere with this test
          FastlaneSpec::Env.with_env_values('SUPPLY_JSON_KEY' => nil) do
            expect(UI).to receive(:important).with("To not be asked about this value, you can specify it using 'json_key'")
            expect(UI).to receive(:input).with(anything).and_return("not_a_file")
            expect(UI).to receive(:user_error!).with(/Could not find service account json file at path*/).and_raise("boom")

            expect do
              Fastlane::FastFile.new.parse("lane :test do
                get_managed_play_store_publishing_rights()
              end").runner.execute(:test)
            end.to raise_error("boom")
          end
        end

        it "found file" do
          # Ensures that people's local environment variable doesn't interfere with this test
          FastlaneSpec::Env.with_env_values('SUPPLY_JSON_KEY' => nil) do
            expect(UI).to receive(:important).with("To not be asked about this value, you can specify it using 'json_key'").once
            expect(UI).to receive(:input).with(anything).and_return(json_key_path)
            expect(UI).to receive(:important).with("https://play.google.com/apps/publish/delegatePrivateApp?service_account=#{json_key_client_email}&continueUrl=https%3A%2F%2Ffastlane.github.io%2Fmanaged_google_play-callback%2Fcallback.html")

            Fastlane::FastFile.new.parse("lane :test do
              get_managed_play_store_publishing_rights()
            end").runner.execute(:test)
          end
        end
      end

      describe "with options" do
        it "with :json_key" do
          expect(UI).to receive(:important).with("https://play.google.com/apps/publish/delegatePrivateApp?service_account=#{json_key_client_email}&continueUrl=https%3A%2F%2Ffastlane.github.io%2Fmanaged_google_play-callback%2Fcallback.html")

          Fastlane::FastFile.new.parse("lane :test do
            get_managed_play_store_publishing_rights(
              json_key: '#{json_key_path}'
            )
          end").runner.execute(:test)
        end

        it "with :json_key_data" do
          # Ensures that people's local environment variable doesn't interfere with this test
          FastlaneSpec::Env.with_env_values('SUPPLY_JSON_KEY' => nil) do
            expect(UI).to receive(:important).with("https://play.google.com/apps/publish/delegatePrivateApp?service_account=#{json_key_client_email}&continueUrl=https%3A%2F%2Ffastlane.github.io%2Fmanaged_google_play-callback%2Fcallback.html")

            Fastlane::FastFile.new.parse("lane :test do
              get_managed_play_store_publishing_rights(
                json_key_data: '#{json_key_data}'
              )
            end").runner.execute(:test)
          end
        end
      end
    end
  end
end
