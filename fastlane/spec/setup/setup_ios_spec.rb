describe Fastlane::SetupIos do
  describe "#setup_ios" do
    let(:setup) { Fastlane::SetupIos.new(user: "user@example.com") }

    before do
      allow(setup).to receive(:welcome_to_fastlane)
      allow(setup).to receive(:fastfile_template_content)
      allow(setup).to receive(:appfile_template_content)
      allow(setup).to receive(:preferred_setup_method).and_return(nil)
      allow(FastlaneCore::UI.ui_object).to receive(:select).and_return("🚀  Automate App Store distribution")
      allow(FastlaneCore::UI).to receive(:important)
      allow(FastlaneCore::UI).to receive(:confirm).and_return(true)
      allow(FastlaneCore::UI).to receive(:error)
      allow(setup).to receive(:ios_manual)
    end

    it "shows the App Store Connect error when it has no preferred error info" do
      allow(setup).to receive(:ios_app_store).and_raise(Spaceship::UnexpectedResponse.new("The App Name you entered is already being used."))

      expect(FastlaneCore::UI).to receive(:error).with("The App Name you entered is already being used.")

      setup.setup_ios
    end
  end

  describe "#create_app_online!" do
    let(:setup) { Fastlane::SetupIos.new(user: "user@example.com") }

    before do
      setup.app_identifier = "com.example.app"
      allow(FastlaneCore::Configuration).to receive(:create)
      allow(FastlaneCore::UI).to receive(:confirm).and_return(false)
      allow(FastlaneCore::UI).to receive(:important)
    end

    it "shows the App Store Connect error when it has no preferred error info" do
      error = Spaceship::UnexpectedResponse.new("The App Name you entered is already being used.")
      allow(Produce::Manager).to receive(:start_producing).and_raise(error)

      expect(FastlaneCore::UI).to receive(:error).with("The App Name you entered is already being used.")
      expect { setup.create_app_online!(mode: :itc) }.to raise_error(error)
    end
  end
end
