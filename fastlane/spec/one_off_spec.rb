require 'fastlane/one_off'

describe Fastlane do
  describe Fastlane::OneOff do
    describe "Valid parameters" do
      before do
        @runner = "runner"
        expect(Fastlane::Runner).to receive(:new).and_return(@runner)
      end

      it "calls load_actions to load all built-in actions" do
        action = 'increment_build_number'
        expect(Fastlane).to receive(:load_actions)

        expect(@runner).to receive(:execute_action).with(
          action, Fastlane::Actions::IncrementBuildNumberAction, [{}], { custom_dir: "." }
        )
        Fastlane::OneOff.execute(args: [action])
      end

      it "works with no parameters" do
        action = 'increment_build_number'

        expect(@runner).to receive(:execute_action).with(
          action, Fastlane::Actions::IncrementBuildNumberAction, [{}], { custom_dir: "." }
        )

        Fastlane::OneOff.execute(args: [action])
      end

      it "automatically converts the parameters" do
        action = 'slack'

        expect(@runner).to receive(:execute_action).with(
          action, Fastlane::Actions::SlackAction, [{ message: "something" }], { custom_dir: "." }
        )

        Fastlane::OneOff.execute(args: [action, "message:something"])
      end
    end
  end
end
