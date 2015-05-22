describe Fastlane do
  describe Fastlane::FastFile do
    describe "reset_git_repo" do
      it "works as expected inside a Fastfile" do
        Fastlane::FastFile.new.parse("lane :test do 
          reset_git_repo :ios
        end").runner.execute(:test)
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DEFAULT_PLATFORM]).to eq(:ios)
      end
    end
  end
end
