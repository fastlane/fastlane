describe Fastlane do
  describe Fastlane::FastFile do
    describe "Deliver Integration" do
      it "uses the snapshot path if given" do
        test_val = "test_val"
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::SNAPSHOT_SCREENSHOTS_PATH] = test_val

        result = Fastlane::FastFile.new.parse("lane :test do
          deliver
        end").runner.execute(:test)

        expect(result[:screenshots_path]).to eq(test_val)
      end

      describe "choosing the binary" do
        around do |example|
          Dir.mktmpdir do |dir|
            Dir.chdir(dir) do
              FileUtils.touch("stale.ipa")
              FileUtils.mkdir_p("build")
              FileUtils.touch("build/App.ipa")
              FileUtils.touch("build/App.pkg")
              example.run
            end
          end
        end

        def run_lane(params = "")
          Fastlane::FastFile.new.parse("lane :test do
            upload_to_app_store(#{params})
          end").runner.execute(:test)
        end

        it "uploads the ipa gym built, not the newest ipa in the current directory" do
          Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH] = File.expand_path("build/App.ipa")

          expect(File.expand_path(run_lane[:ipa])).to eq(File.expand_path("build/App.ipa"))
        end

        it "uploads an ipa given explicitly over the one gym built" do
          Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH] = File.expand_path("build/App.ipa")

          expect(File.expand_path(run_lane("ipa: 'stale.ipa'")[:ipa])).to eq(File.expand_path("stale.ipa"))
        end

        it "does not add an ipa from an earlier build when a pkg is given" do
          FileUtils.rm("stale.ipa")
          Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH] = File.expand_path("build/App.ipa")

          values = run_lane("pkg: 'build/App.pkg'")

          expect(values[:ipa]).to be_nil
          expect(File.expand_path(values[:pkg])).to eq(File.expand_path("build/App.pkg"))
        end
      end

      it "uses the ipa path if given and raises an error if not available" do
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH] = "something.ipa"

        expect do
          Fastlane::FastFile.new.parse("lane :test do
            deliver
          end").runner.execute(:test)
        end.to raise_error(/Could not find ipa file at path '/)
      end
    end
  end
end
