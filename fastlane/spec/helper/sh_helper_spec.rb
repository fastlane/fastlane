describe Fastlane::Actions do
  describe "#sh" do
    let (:mock_input) { double :input }
    let (:mock_status) { double :status }
    let (:mock_thread) { double :thread, value: mock_status }
    # Just open an empty file to mock command output
    let (:mock_output) { File.open(File.expand_path(File.join("..", "..", "fixtures", "appfiles", "Appfile_empty"), __FILE__)) }

    before do
      allow(FastlaneCore::Helper).to receive(:sh_enabled?).and_return(true)
    end

    context "external commands are failed" do
      context "with error_callback" do
        it "doesn't raise shell_error" do
          allow(FastlaneCore::UI).to receive(:error)
          called = false
          expect_command "exit 1", 1
          Fastlane::Actions.sh("exit 1", error_callback: ->(_) { called = true })

          expect(called).to be true
          expect(FastlaneCore::UI).to have_received(:error).with("Exit status of command 'exit 1' was 1 instead of 0.\n")
        end
      end

      context "without error_callback" do
        it "raise shell_error" do
          allow(FastlaneCore::UI).to receive(:shell_error!)
          expect_command "exit 1", 1
          Fastlane::Actions.sh("exit 1")

          expect(UI).to have_received(:shell_error!).with("Exit status of command 'exit 1' was 1 instead of 0.\n")
        end
      end
    end

    context "handling of array arguments" do
      it "joins arrays into a single string" do
        expect_command "git commit"
        Fastlane::Actions.sh(%w(git commit))
      end

      it "shell escapes array elements" do
        expect_command 'git commit -m a\ message'
        Fastlane::Actions.sh(["git", "commit", "-m", "a message"])
      end

      it "converts array elements to strings" do
        pathname = Pathname.new "."
        expect_command 'git commit . -m a\ message'
        Fastlane::Actions.sh(["git", "commit", pathname, "-m", "a message"])
      end
    end
  end
end

def expect_command(command, exitstatus = 0)
  require "open3"

  allow(mock_status).to receive(:exitstatus) { exitstatus }
  expect(Open3).to receive(:popen2e).with(command).and_yield mock_input, mock_output, mock_thread
end
