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
