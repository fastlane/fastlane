require "fastlane/new_action"

describe Fastlane::NewAction do
  describe ".generate_action" do
    it "writes a valid action from the template" do
      Dir.mktmpdir do |dir|
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(dir)
        allow(FastlaneCore::UI).to receive(:success)

        Fastlane::NewAction.generate_action("my_custom_action")

        source = File.read(File.join(dir, "actions", "my_custom_action.rb"))
        expect(source).not_to include("[[")
        expect(RubyVM::InstructionSequence.compile(source)).to be_truthy
        expect(source).to include("class MyCustomActionAction < Action")
      end
    end
  end
end
