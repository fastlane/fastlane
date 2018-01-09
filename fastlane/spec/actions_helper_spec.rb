describe Fastlane do
  describe Fastlane::FastFile do
    describe "#execute_action" do
      let(:step_name) { "My Step" }

      it "stores the action properly" do
        Fastlane::Actions.execute_action(step_name) {}
        result = Fastlane::Actions.executed_actions.last
        expect(result[:name]).to eq(step_name)
        expect(result[:error]).to eq(nil)
      end

      it "stores the action properly when an exeception occurred" do
        expect do
          Fastlane::Actions.execute_action(step_name) do
            UI.user_error!("Some error")
          end
        end.to raise_error("Some error")

        result = Fastlane::Actions.executed_actions.last
        expect(result[:name]).to eq(step_name)
        expect(result[:error]).to include("Some error")
        expect(result[:error]).to include("actions_helper.rb")
      end
    end

    it "#action_class_ref" do
      expect(Fastlane::Actions.action_class_ref("gym")).to eq(Fastlane::Actions::GymAction)
      expect(Fastlane::Actions.action_class_ref(:cocoapods)).to eq(Fastlane::Actions::CocoapodsAction)
      expect(Fastlane::Actions.action_class_ref('notExistentObv')).to eq(nil)
    end

    it "#load_default_actions" do
      expect(Fastlane::Actions.load_default_actions.count).to be > 6
    end

    describe "#load_external_actions" do
      it "can load custom paths" do
        Fastlane::Actions.load_external_actions("./fastlane/spec/fixtures/actions")
        Fastlane::Actions::ExampleActionAction.run(nil)
        Fastlane::Actions::ExampleActionSecondAction.run(nil)
        Fastlane::Actions::ArchiveAction.run(nil)
      end

      it "can throws an error if plugin is damaged" do
        expect(UI).to receive(:user_error!).with("Action 'broken_action' is damaged!", { show_github_issues: true })
        Fastlane::Actions.load_external_actions("./fastlane/spec/fixtures/broken_actions")
      end
    end

    describe "#deprecated_actions" do
      it "is class action" do
        Fastlane::Actions.load_external_actions("./fastlane/spec/fixtures/actions")
        require_relative './fixtures/broken_actions/broken_action.rb'

        # An action
        example_action_ref = Fastlane::Actions.action_class_ref("example_action")
        expect(Fastlane::Actions.is_class_action?(example_action_ref)).to eq(true)

        # Not an action
        broken_action_ref = Fastlane::Actions::BrokenAction
        expect(Fastlane::Actions.is_class_action?(broken_action_ref)).to eq(false)

        # Nil
        expect(Fastlane::Actions.is_class_action?(nil)).to eq(false)
      end

      it "is action deprecated" do
        Fastlane::Actions.load_external_actions("./fastlane/spec/fixtures/actions")
        require_relative './fixtures/broken_actions/broken_action.rb'
        require_relative './fixtures/deprecated_actions/deprecated_action.rb'

        # An action (not deprecated)
        example_action_ref = Fastlane::Actions.action_class_ref("example_action")
        expect(Fastlane::Actions.is_deprecated?(example_action_ref)).to eq(false)

        # An action (depreated)
        deprecated_action_ref = Fastlane::Actions.action_class_ref("deprecated_action")
        expect(Fastlane::Actions.is_deprecated?(deprecated_action_ref)).to eq(true)

        # Not an action
        broken_action_ref = Fastlane::Actions::BrokenAction
        expect(Fastlane::Actions.is_deprecated?(broken_action_ref)).to eq(false)

        # Nil
        expect(Fastlane::Actions.is_deprecated?(nil)).to eq(false)
      end
    end
  end
end
