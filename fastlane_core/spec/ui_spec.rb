require 'spec_helper'

describe FastlaneCore::UI do
  it "uses a FastlaneCore::Shell by default" do
    expect(FastlaneCore::UI.ui_object).to be_kind_of(FastlaneCore::Shell)
  end

  it "redirects all method calls to the current UI object" do
    expect(FastlaneCore::UI.ui_object).to receive(:error).with("yolo")
    FastlaneCore::UI.error("yolo")
  end

  it "allows overwriting of the ui_object for fastlane.ci" do
    third_party_output = "third_party_output"
    FastlaneCore::UI.ui_object = third_party_output

    expect(third_party_output).to receive(:error).with("yolo")
    FastlaneCore::UI.error("yolo")

    FastlaneCore::UI.ui_object = nil
  end
end
