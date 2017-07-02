describe Fastlane::Actions do
  describe "#sh" do
    before do
      allow(FastlaneCore::Helper).to receive(:sh_enabled?).and_return(true)
    end

    context "external commands are failed" do
      context "with error_callback" do
        it "doesn't raise shell_error" do
          allow(FastlaneCore::UI).to receive(:error)
          called = false
          Fastlane::Actions.sh("exit 1", error_callback: ->(_) { called = true })

          expect(called).to be true
          expect(FastlaneCore::UI).to have_received(:error).with("Exit status of command 'exit 1' was 1 instead of 0.\n")
        end
      end

      context "without error_callback" do
        it "raise shell_error" do
          allow(FastlaneCore::UI).to receive(:shell_error!)
          Fastlane::Actions.sh("exit 1")

          expect(UI).to have_received(:shell_error!).with("Exit status of command 'exit 1' was 1 instead of 0.\n")
        end
      end
    end
  end
end
