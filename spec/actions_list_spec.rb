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

    describe "Actions provide a complete documenation" do
      Fastlane::ActionsList.all_actions do |action, name|
        it "Valid return values for fastlane action '#{name}'" do
          expect(action.superclass).to eq(Fastlane::Action), "Please add `Action` as a superclass for action '#{name}'"

          expect(action.description.length).to be <= 80, "Provided description for '#{name}'-action is too long"
          expect(action.description.length).to be > 5, "Provided description for '#{name}'-action is too short"
          expect(action.description.strip.end_with? '.').to eq(false), "The description of '#{name}' shouldn't end with a `.`"
          action.is_supported?(nil) # this will raise an exception if the method is not implemented

          expect(action).to be < Fastlane::Action

          authors = Array(action.author || action.authors)
          expect(authors.count).to be >= 1, "Action '#{name}' must have at least one author"

          authors.each do |author|
            expect(author).to_not start_with("@")
          end

          if action.available_options
            expect(action.available_options).to be_instance_of(Array), "'available_options' for action '#{name}' must be an array"
          end

          if action.output
            expect(action.output).to be_instance_of(Array), "'output' for action '#{name}' must be an array"
          end

          if action.details
            expect(action.details).to be_instance_of(String), "'details' for action '#{name}' must be a String"
          end
        end
      end
    end

    it "allows filtering of the platforms" do
      count = 0
      Fastlane::ActionsList.all_actions("nothing special") { count += 1 }
      expect(count).to be > 40
      expect(count).to be < 80
    end

    describe "Provide action details" do
      Fastlane::ActionsList.all_actions do |action, name|
        it "Shows the details for action '#{name}'" do
          Fastlane::ActionsList.show_details(filter: name)
        end
      end
    end
  end
end
