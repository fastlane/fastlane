require 'spec_helper'

describe FastlaneCore do
  describe FastlaneCore::Globals do
    it "Toggle verbose mode" do
      FastlaneCore::Globals.verbose = true
      expect(FastlaneCore::Globals.verbose?).to eq(true)
      FastlaneCore::Globals.verbose = false
      expect(FastlaneCore::Globals.verbose?).to eq(nil)
    end

    it "Toggle capture_mode " do
      FastlaneCore::Globals.capture_output = true
      expect(FastlaneCore::Globals.capture_output?).to eq(true)
      FastlaneCore::Globals.capture_output = false
      expect(FastlaneCore::Globals.capture_output?).to eq(nil)
    end
  end
end
