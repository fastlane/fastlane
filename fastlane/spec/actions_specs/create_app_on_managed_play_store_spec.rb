describe Fastlane do
  describe Fastlane::FastFile do
    describe "create_app_on_managed_play_store" do
      let(:json_key_path) { File.expand_path("./fastlane/spec/fixtures/google_play/google_play.json") }
      let(:json_key_data) { File.open(json_key_path, 'rb').read }
      let(:mock_client) { Object.new }

      describe "without :json_key or :json_key_data" do
        it "without :json_key or :json_key_data - could not find file" do
          expect(UI).to receive(:interactive?).and_return(true)
          expect(UI).to receive(:important).with("To not be asked about this value, you can specify it using 'json_key'")
          expect(UI).to receive(:input).with(anything).and_return("not_a_file")
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              create_app_on_managed_play_store()
            end").runner.execute(:test)
          end.to raise_error(FastlaneCore::Interface::FastlaneError, /Could not find service account json file at path/)
        end

        it "without :json_key or :json_key_data - crashes in a not an interactive place" do
          expect(UI).to receive(:interactive?).and_return(false)
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              create_app_on_managed_play_store()
            end").runner.execute(:test)
          end.to raise_error(FastlaneCore::Interface::FastlaneError, "Could not load Google authentication. Make sure it has been added as an environment variable in 'json_key' or 'json_key_data'")
        end
      end

      describe "with :json_key or :json_key_data" do
        let(:app_title) { "App Title" }
        let(:language) { "en_US" }
        let(:developer_account_id) { "123456789" }
        let(:apk) { "apk.apk" }

        before(:each) do
          allow(PlaycustomappClient).to receive(:make_from_config).with(anything).and_return(mock_client)
        end

        it "without :app_title" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              create_app_on_managed_play_store(
                json_key: '#{json_key_path}'
              )
            end").runner.execute(:test)
          end.to raise_error(FastlaneCore::Interface::FastlaneError, "No value found for 'app_title'")
        end

        it "without :developer_account_id" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              create_app_on_managed_play_store(
                json_key: '#{json_key_path}',
                app_title: '#{app_title}'
              )
            end").runner.execute(:test)
          end.to raise_error(FastlaneCore::Interface::FastlaneError, "No value found for 'developer_account_id'")
        end

        it "without :apk" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              create_app_on_managed_play_store(
                json_key: '#{json_key_path}',
                app_title: '#{app_title}',
                developer_account_id: '#{developer_account_id}',
                apk: nil
              )
            end").runner.execute(:test)
          end.to raise_error(FastlaneCore::Interface::FastlaneError, "No value found for 'apk'")
        end

        describe "with :apk" do
          before(:each) do
            expect(File).to receive(:exist?).with('apk.apk').and_return(true)
            allow(File).to receive(:exist?).with(anything).and_call_original
          end

          it "success" do
            expect(mock_client).to receive(:create_app).with({
              app_title: app_title,
              language_code: language,
              developer_account: developer_account_id,
              apk_path: apk
            })

            Fastlane::FastFile.new.parse("lane :test do
              create_app_on_managed_play_store(
                json_key: '#{json_key_path}',
                app_title: '#{app_title}',
                developer_account_id: '#{developer_account_id}',
                apk: '#{apk}'
              )
            end").runner.execute(:test)
          end

          it "failure with invalid :language" do
            expect do
              Fastlane::FastFile.new.parse("lane :test do
                create_app_on_managed_play_store(
                  json_key: '#{json_key_path}',
                  app_title: '#{app_title}',
                  developer_account_id: '#{developer_account_id}',
                  apk: '#{apk}',
                  language: 'fast_lang'
                )
              end").runner.execute(:test)
            end.to raise_error(FastlaneCore::Interface::FastlaneError, /Please enter one of the available languages/)
          end
        end
      end
    end
  end
end
