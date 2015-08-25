describe Fastlane do
  describe Fastlane::FastFile do
    describe "Deliver Integration" do
      let (:test_path) { "/tmp/fastlane/tests/fastlane" }
      let (:app_identifier) { "net.sunapps.54" }
      let (:apple_id) { "deliver@krausefx.com" }

      before do
        ENV.delete('DELIVER_SCREENSHOTS_PATH')
        ENV.delete('DELIVER_SKIP_BINARY')

        @app_file = File.join(test_path, "Appfile")
        @deliver_file = File.join(test_path, "Deliverfile")

        FileUtils.mkdir_p(test_path)
        File.write(@app_file, "app_identifier '#{app_identifier}'; apple_id '#{apple_id}'")
        File.write(@deliver_file, "")
      end

      it "works with custom setting and sets the correct snapshot path" do
        test_val = "test_val"
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::SNAPSHOT_SCREENSHOTS_PATH] = test_val

        Dir.chdir(test_path) do
          Fastlane::FastFile.new.parse("lane :test do
            deliver(
              force: true,
              beta: true,
              skip_deploy: true
            )
          end").runner.execute(:test)

          expect(ENV['DELIVER_SCREENSHOTS_PATH']).to eq(test_val)
        end
      end

      it "raises an error if deliver_path can't be found" do
        Dir.chdir(test_path) do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              deliver(
                deliver_file_path: '../nothere'
              )
            end").runner.execute(:test)
          end.to raise_error("Couldn't find folder '../nothere'. Make sure to pass the path to the directory not the file!".red)
        end
      end

      it "supports the metadata_only option" do
        Dir.chdir(test_path) do
          Fastlane::FastFile.new.parse("lane :test do
            deliver(
              metadata_only: true
            )
          end").runner.execute(:test)

          expect(ENV['DELIVER_SKIP_BINARY']).to eq("1")
        end
      end

      after do
        File.delete(@app_file)
        File.delete(@deliver_file)
      end
    end
  end
end
