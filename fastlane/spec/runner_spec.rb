describe Fastlane do
  describe Fastlane::Runner do
    describe "#available_lanes" do
      before do
        @ff = Fastlane::FastFile.new('./fastlane/spec/fixtures/fastfiles/FastfileGrouped')
      end

      it "lists all available lanes" do
        expect(@ff.runner.available_lanes).to eq(["test", "anotherroot", "mac beta", "ios beta", "ios release", "android beta", "android witherror", "android unsupported_action"])
      end

      it "allows filtering of results" do
        expect(@ff.runner.available_lanes('android')).to eq(["android beta", "android witherror", "android unsupported_action"])
      end

      it "returns an empty array if invalid input is given" do
        expect(@ff.runner.available_lanes('asdfasdfasdf')).to eq([])
      end

      it "doesn't show private lanes" do
        expect(@ff.runner.available_lanes).to_not(include('android such_private'))
      end
      describe "step_name override" do
        it "handle overriding of step_name" do
          allow(Fastlane::Actions).to receive(:execute_action).with('Let it Frame')
          @ff.runner.execute_action(:frameit, Fastlane::Actions::FrameitAction, [{ step_name: "Let it Frame" }])
        end
        it "rely on step_text when no step_name given" do
          allow(Fastlane::Actions).to receive(:execute_action).with('frameit')

          @ff.runner.execute_action(:frameit, Fastlane::Actions::FrameitAction, [{}])
        end
      end
    end
  end
end
