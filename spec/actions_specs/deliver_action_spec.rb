describe Fastlane do
  describe Fastlane::FastFile do
    describe "Deliver Integration" do
      let (:test_path) { "/tmp/fastlane/tests/fastlane" }
      let (:app_identifier) { "net.sunapps.54" }
      let (:apple_id) { "krausefx@gmail.com" }

      before do
        @app_file = File.join(test_path, "Appfile")
        @deliver_file = File.join(test_path, "Deliverfile")

        FileUtils.mkdir_p(test_path)
        File.write(@app_file, "app_identifier '#{app_identifier}'; apple_id '#{apple_id}'")
        File.write(@deliver_file, "")
      end

      it "works with default setting" do
        test_val = "test_val"
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::SNAPSHOT_SCREENSHOTS_PATH] = test_val

        Dir.chdir(test_path) do
          expect {
            
            Fastlane::FastFile.new.parse("lane :test do 
              deliver
            end").runner.execute(:test)

          }.to raise_error('You have to pass a valid version number using the Deliver file. (e.g. \'version "1.0"\')'.red)

          expect(ENV['DELIVER_SCREENSHOTS_PATH']).to eq(test_val)
        end
      end

      it "works with custom setting" do
        test_val = "test_val"
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::SNAPSHOT_SCREENSHOTS_PATH] = test_val

        Dir.chdir(test_path) do
          expect {
            
            Fastlane::FastFile.new.parse("lane :test do 
              deliver(
                force: true,
                beta: true,
                skip_deploy: true,
                deliver_file_path: '../example'
              )
            end").runner.execute(:test)

          }.to raise_error("Couldn't find folder '../example'. Make sure to pass the path to the directory not the file!".red)

          expect(ENV['DELIVER_SCREENSHOTS_PATH']).to eq(test_val)
        end
      end

      after do
        File.delete(@app_file)
        File.delete(@deliver_file)
      end

    end
  end
end
