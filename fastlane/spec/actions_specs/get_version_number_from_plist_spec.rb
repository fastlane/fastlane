describe Fastlane do
  describe Fastlane::FastFile do
    describe "Get Version Number from Info.plist Integration" do
      it "should return version number from Info.plist" do
        result = Fastlane::FastFile.new.parse("lane :test do
          get_version_number_from_plist
        end").runner.execute(:test)
        expect(result).to eq("0.9.14")
      end

      it "should set VERSION_NUMBER shared value" do
        Fastlane::FastFile.new.parse("lane :test do
          get_version_number_from_plist
        end").runner.execute(:test)
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to eq("0.9.14")
      end
    end
  end
end
