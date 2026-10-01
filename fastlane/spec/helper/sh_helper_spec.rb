require "stringio"

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
          expect_command("exit 1", exitstatus: 1)
          Fastlane::Actions.sh("exit 1", error_callback: ->(_) { called = true })

          expect(called).to be(true)
          expect(FastlaneCore::UI).to have_received(:error).with("Exit status of command 'exit 1' was 1 instead of 0.\n")
        end
      end

      context "without error_callback" do
        it "raise shell_error" do
          allow(FastlaneCore::UI).to receive(:shell_error!)
          expect_command("exit 1", exitstatus: 1)
          Fastlane::Actions.sh("exit 1")

          expect(UI).to have_received(:shell_error!).with("Exit status of command 'exit 1' was 1 instead of 0.\n")
        end

        it "includes command output in error message when not a TTY" do
          allow(FastlaneCore::UI).to receive(:shell_error!)
          expect_command("exit 1", exitstatus: 1, output: "Error details")
          allow($stdout).to receive(:isatty).and_return(false)
          Fastlane::Actions.sh("exit 1")

          expect(UI).to have_received(:shell_error!).with(match(/Error details/))
        end

        it "does not include command output in error message when it is a TTY" do
          allow(FastlaneCore::UI).to receive(:shell_error!)
          expect_command("exit 1", exitstatus: 1, output: "Error details")
          allow($stdout).to receive(:isatty).and_return(true)
          Fastlane::Actions.sh("exit 1")

          expect(UI).to have_received(:shell_error!).with("Exit status of command 'exit 1' was 1 instead of 0.\n")
        end
      end
    end

    context "command output encoding" do
      it "prints valid UTF-8 output without a warning" do
        allow(FastlaneCore::UI).to receive(:command_output)
        allow(FastlaneCore::UI).to receive(:important)
        expect_command("ls", output: "hello world\n")

        Fastlane::Actions.sh("ls")

        expect(FastlaneCore::UI).to have_received(:command_output).with("hello world")
        expect(FastlaneCore::UI).to_not(have_received(:important))
      end

      it "sanitizes invalid UTF-8 output and warns the user" do
        allow(FastlaneCore::UI).to receive(:command_output)
        allow(FastlaneCore::UI).to receive(:important)
        # "\xC3\x28" is an invalid UTF-8 byte sequence that would make `strip` raise.
        expect_command("cat", output: "before \xC3\x28 after\n".dup.force_encoding("UTF-8"))

        Fastlane::Actions.sh("cat")

        expect(FastlaneCore::UI).to have_received(:command_output).with("before �( after")
        expect(FastlaneCore::UI).to have_received(:important).with(/UTF-8/)
      end

      it "warns only once even when multiple lines are invalid UTF-8" do
        allow(FastlaneCore::UI).to receive(:command_output)
        allow(FastlaneCore::UI).to receive(:important)
        output = "bad \xC3\x28 one\nbad \xC3\x28 two\nbad \xC3\x28 three\n".dup.force_encoding("UTF-8")
        expect_command("cat", output: output)

        Fastlane::Actions.sh("cat")

        expect(FastlaneCore::UI).to have_received(:important).with(/UTF-8/).once
      end

      it "does not raise when stripping invalid UTF-8 output" do
        allow(FastlaneCore::UI).to receive(:command_output)
        allow(FastlaneCore::UI).to receive(:important)
        expect_command("cat", output: "\xFF\xFE bad bytes\n".dup.force_encoding("UTF-8"))

        expect do
          Fastlane::Actions.sh("cat")
        end.to_not(raise_error)
      end

      it "does not print or warn when print_command_output is false" do
        allow(FastlaneCore::UI).to receive(:command_output)
        allow(FastlaneCore::UI).to receive(:important)
        expect_command("cat", output: "before \xC3\x28 after\n".dup.force_encoding("UTF-8"))

        Fastlane::Actions.sh_control_output("cat", print_command: false, print_command_output: false)

        expect(FastlaneCore::UI).to_not(have_received(:command_output))
        expect(FastlaneCore::UI).to_not(have_received(:important))
      end

      it "keeps the raw (unsanitized) bytes in the returned result" do
        allow(FastlaneCore::UI).to receive(:command_output)
        allow(FastlaneCore::UI).to receive(:important)
        raw = "before \xC3\x28 after\n".dup.force_encoding("UTF-8")
        expect_command("cat", output: raw)

        result = Fastlane::Actions.sh("cat")

        expect(result).to eq(raw)
      end
    end

    context "passing command arguments to the system" do
      it "passes a string as a string" do
        expect_command("git commit")
        Fastlane::Actions.sh("git commit")
      end

      it "passes a list" do
        expect_command("git", "commit")
        Fastlane::Actions.sh("git", "commit")
      end

      it "passes an environment Hash" do
        expect_command({ "PATH" => "/usr/local/bin" }, "git", "commit")
        Fastlane::Actions.sh({ "PATH" => "/usr/local/bin" }, "git", "commit")
      end

      it "allows override of argv[0]" do
        expect_command(["/usr/local/bin/git", "git"], "commit", "-m", "A message")
        Fastlane::Actions.sh(["/usr/local/bin/git", "git"], "commit", "-m", "A message")
      end

      it "allows a single array to be passed to support older Fastlane syntax" do
        expect_command("ls -la /tmp")
        Fastlane::Actions.sh(["ls -la", "/tmp"])
      end

      it "does not automatically escape array arguments from older fastlane syntax" do
        expect_command('git log --oneline')
        Fastlane::Actions.sh(["git", "log --oneline"])
      end
    end

    context "with a postfix block" do
      it "yields the status, result and command" do
        expect_command("ls", "-la")
        Fastlane::Actions.sh("ls", "-la") do |status, result, command|
          expect(status.exitstatus).to eq(0)
          expect(result).to be_empty
          expect(command).to eq("ls -la")
        end
      end

      it "yields any error result" do
        expect_command("ls", "-la", exitstatus: 1)
        Fastlane::Actions.sh("ls", "-la") do |status, result|
          expect(status.exitstatus).to eq(1)
          expect(result).to be_empty
        end
      end

      it "yields command output" do
        expect_command("ls", "-la", exitstatus: 1, output: "Heeeelp! Something went wrong.")
        Fastlane::Actions.sh("ls", "-la") do |status, result|
          expect(status.exitstatus).to eq(1)
          expect(result).to eq("Heeeelp! Something went wrong.")
        end
      end

      it "returns the return value of the block if present" do
        expect_command("ls", "-la")
        return_value = Fastlane::Actions.sh("ls", "-la") do |status, result|
          42
        end
        expect(return_value).to eq(42)
      end
    end
  end

  describe "shell_command_from_args" do
    it 'returns the string when a string is passed' do
      command = command_from_args("git commit -m 'A message'")
      expect(command).to eq("git commit -m 'A message'")
    end

    it 'raises when no argument passed' do
      expect do
        command_from_args
      end.to raise_error(ArgumentError)
    end

    it 'shelljoins multiple args' do
      message = "A message"
      command = command_from_args("git", "commit", "-m", message)
      expect(command).to eq("git commit -m #{message.shellescape}")
    end

    it 'adds an environment Hash at the beginning' do
      message = "A message"
      command = command_from_args({ "PATH" => "/usr/local/bin" }, "git", "commit", "-m", message)
      expect(command).to eq("PATH=/usr/local/bin git commit -m #{message.shellescape}")
    end

    it 'shell-escapes environment variable values' do
      message = "A message"
      path = "/usr/my local/bin"
      command = command_from_args({ "PATH" => path }, "git", "commit", "-m", message)
      expect(command).to eq("PATH=#{path.shellescape} git commit -m #{message.shellescape}")
    end

    it 'recognizes an array as the only element of a command' do
      command = command_from_args(["/usr/local/bin/git", "git"])
      expect(command).to eq("/usr/local/bin/git")
    end

    it 'recognizes an array as the first element of a command' do
      message = "A message"
      command = command_from_args(["/usr/local/bin/git", "git"], "commit", "-m", message)
      expect(command).to eq("/usr/local/bin/git commit -m #{message.shellescape}")
    end
  end
end

def command_from_args(*args)
  Fastlane::Actions.shell_command_from_args(*args)
end

def expect_command(*command, exitstatus: 0, output: "")
  mock_input = double(:input)
  mock_output = StringIO.new(output)
  mock_status = double(:status, exitstatus: exitstatus)
  mock_thread = double(:thread, value: mock_status)

  expect(Open3).to receive(:popen2e).with(*command).and_yield(mock_input, mock_output, mock_thread)
end
