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
          expect_command "exit 1", exitstatus: 1
          Fastlane::Actions.sh("exit 1", error_callback: ->(_) { called = true })

          expect(called).to be true
          expect(FastlaneCore::UI).to have_received(:error).with("Exit status of command 'exit 1' was 1 instead of 0.\n")
        end
      end

      context "without error_callback" do
        it "raise shell_error" do
          allow(FastlaneCore::UI).to receive(:shell_error!)
          expect_command "exit 1", exitstatus: 1
          Fastlane::Actions.sh("exit 1")

          expect(UI).to have_received(:shell_error!).with("Exit status of command 'exit 1' was 1 instead of 0.\n")
        end
      end
    end

    context "passing command arguments to the system" do
      it "passes a string as a string" do
        expect_command "git commit"
        Fastlane::Actions.sh "git commit"
      end

      it "passes a list" do
        expect_command "git", "commit"
        Fastlane::Actions.sh "git", "commit"
      end

      it "passes an environment Hash" do
        expect_command({ "PATH" => "/usr/local/bin" }, "git", "commit")
        Fastlane::Actions.sh({ "PATH" => "/usr/local/bin" }, "git", "commit")
      end

      it "allows override of argv[0]" do
        expect_command ["/usr/local/bin/git", "git"], "commit", "-m", "A message"
        Fastlane::Actions.sh ["/usr/local/bin/git", "git"], "commit", "-m", "A message"
      end
    end
  end

  describe "shell_command_from_args" do
    it 'returns the string when a string is passed' do
      command = command_from_args "git commit -m 'A message'"
      expect(command).to eq "git commit -m 'A message'"
    end

    it 'raises when no argument passed' do
      expect do
        command_from_args
      end.to raise_error ArgumentError
    end

    it 'shelljoins multiple args' do
      command = command_from_args "git", "commit", "-m", "A message"
      expect(command).to eq 'git commit -m A\ message'
    end

    it 'adds an environment Hash at the beginning' do
      command = command_from_args({ "PATH" => "/usr/local/bin" }, "git", "commit", "-m", "A message")
      expect(command).to eq 'PATH=/usr/local/bin git commit -m A\ message'
    end

    it 'shell-escapes environment variable values' do
      command = command_from_args({ "PATH" => "/usr/my local/bin" }, "git", "commit", "-m", "A message")
      expect(command).to eq 'PATH=/usr/my\ local/bin git commit -m A\ message'
    end

    it 'recognizes an array as the only element of a command' do
      command = command_from_args ["/usr/local/bin/git", "git"]
      expect(command).to eq "/usr/local/bin/git"
    end

    it 'recognizes an array as the first element of a command' do
      command = command_from_args ["/usr/local/bin/git", "git"], "commit", "-m", "A message"
      expect(command).to eq '/usr/local/bin/git commit -m A\ message'
    end
  end
end

def command_from_args(*args)
  Fastlane::Actions.shell_command_from_args(*args)
end

def expect_command(*command, exitstatus: 0)
  mock_input = double :input
  mock_output = File.open(File.expand_path(File.join("..", "..", "fixtures", "appfiles", "Appfile_empty"), __FILE__))
  mock_status = double :status, exitstatus: exitstatus
  mock_thread = double :thread, value: mock_status

  expect(Open3).to receive(:popen2e).with(*command).and_yield mock_input, mock_output, mock_thread
end
