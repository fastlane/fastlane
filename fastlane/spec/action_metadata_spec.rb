require 'fastlane/documentation/actions_list'

describe Fastlane::Action do
  Fastlane::ActionsList.all_actions do |action, name|
    describe name do
      it "contains a valid category" do
        expect(action.category).to_not be_nil
        expect(action.category).to be_kind_of(Symbol)
        expect(Fastlane::Action::AVAILABLE_CATEGORIES).to include(action.category), "Unknown action category '#{action.category}', must be one of #{Fastlane::Action::AVAILABLE_CATEGORIES.join(', ')}"
      end

      it "is a subclass of Action" do
        expect(action.superclass).to eq(Fastlane::Action), "Please add `Action` as a superclass for action '#{name}'"
      end

      it "description" do
        expect(action.description.length).to be <= 80, "Provided description for '#{name}'-action is too long"
        expect(action.description.length).to be > 5, "Provided description for '#{name}'-action is too short"
        expect(action.description.strip.end_with?('.')).to eq(false), "The description of '#{name}' shouldn't end with a `.`"
      end

      it "implements is_supported?" do
        action.is_supported?(nil) # this will raise an exception if the method is not implemented
      end

      it "defines valid authors" do
        authors = Array(action.author || action.authors)
        expect(authors.count).to be >= 1, "Action '#{name}' must have at least one author"

        authors.each do |author|
          expect(author).to_not start_with("@")
        end
      end

      it "available_options" do
        if action.available_options
          expect(action.available_options).to be_instance_of(Array), "'available_options' for action '#{name}' must be an array"
        end
      end

      it "output" do
        if action.output
          expect(action.output).to be_instance_of(Array), "'output' for action '#{name}' must be an array"
        end
      end

      it "details" do
        if action.details
          expect(action.details).to be_instance_of(String), "'details' for action '#{name}' must be a String"
        end
      end
    end
  end
end
