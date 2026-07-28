require 'fastlane/console'

describe Fastlane::Console do
  describe '.execute' do
    let(:irb_instance) { instance_double(IRB::Irb) }
    let(:irb_context) { instance_double(IRB::Context) }

    before do
      allow(IRB).to receive(:setup)
      allow(IRB::Irb).to receive(:new).and_return(irb_instance)
      allow(irb_instance).to receive(:context).and_return(irb_context)
      allow(irb_context).to receive(:prompt_mode=)
      allow(irb_instance).to receive(:signal_handle)
      allow(irb_instance).to receive(:eval_input)

      IRB.conf[:PROMPT] ||= {}
      IRB.conf[:PROMPT][:SIMPLE] ||= {}
    end

    it "sets up IRB with a workspace passed to the constructor" do
      expect(IRB::WorkSpace).to receive(:new).with(an_instance_of(Binding)).and_call_original
      expect(IRB::Irb).to receive(:new).with(an_instance_of(IRB::WorkSpace)).and_return(irb_instance)

      Fastlane::Console.execute([], {})
    end

    it "configures the FASTLANE prompt mode" do
      expect(irb_context).to receive(:prompt_mode=).with(:FASTLANE)

      Fastlane::Console.execute([], {})

      expect(IRB.conf[:PROMPT][:FASTLANE][:RETURN]).to eq("%s\n")
    end

    it "displays the welcome message" do
      expect(Fastlane::UI).to receive(:message).with('Welcome to fastlane interactive!')

      Fastlane::Console.execute([], {})
    end

    it "starts the IRB eval loop" do
      expect(irb_instance).to receive(:eval_input)

      Fastlane::Console.execute([], {})
    end
  end
end
