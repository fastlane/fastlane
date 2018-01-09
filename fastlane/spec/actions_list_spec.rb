require 'fastlane/documentation/actions_list'

describe Fastlane do
  describe "Action List" do
    it "doesn't throw an exception" do
      Fastlane::ActionsList.run(filter: nil)
    end

    it "doesn't throw an exception with filter" do
      Fastlane::ActionsList.run(filter: 'deliver')
    end

    it "shows all available actions if action can't be found" do
      Fastlane::ActionsList.run(filter: 'nonExistingHere')
    end

    it "returns all available actions with the type `Class`" do
      actions = []
      Fastlane::ActionsList.all_actions do |a|
        actions << a
        expect(a.class).to eq(Class)
      end
      expect(actions.count).to be > 80
    end

    it "allows filtering of the platforms" do
      count = 0
      Fastlane::ActionsList.all_actions("nothing special") { count += 1 }
      expect(count).to be > 40
      expect(count).to be < 120
    end

    describe "Provide action details" do
      Fastlane::ActionsList.all_actions do |action, name|
        it "Shows the details for action '#{name}'" do
          Fastlane::ActionsList.show_details(filter: name)
        end
      end
    end

    describe "with a class in the Actions namespace that does not extend action" do
      it "trying to show its details presents a helpful error message" do
        require_relative 'fixtures/broken_actions/broken_action.rb'

        expect(UI).to receive(:user_error!).with(/be a subclass/).and_raise("boom")

        expect do
          Fastlane::ActionsList.show_details(filter: 'broken')
        end.to raise_error("boom")
      end
    end
  end
end
