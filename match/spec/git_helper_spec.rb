describe Match do
  describe Match::GitHelper do
    describe "generate_commit_message" do
      it "works" do
        values = {
          app_identifier: "tools.fastlane.app",
          type: "appstore",
          platform: "ios"
        }
        result = Match::GitHelper.generate_commit_message(values)
        expect(result).to eq("[fastlane] Updated appstore and platform ios")
      end
    end

    describe "#clone" do
      it "skips README file generation if so requested" do
        path = Dir.mktmpdir # to have access to the actual path
        expect(Dir).to receive(:mktmpdir).and_return(path)
        git_url = "https://github.com/fastlane/fastlane/tree/master/certificates"
        shallow_clone = false
        command = "GIT_TERMINAL_PROMPT=0 git clone '#{git_url}' '#{path}'"
        to_params = {
          command: command,
          print_all: nil,
          print_command: nil
        }

        expect(FastlaneCore::CommandExecutor).
          to receive(:execute).
          with(to_params).
          and_return(nil)

        result = Match::GitHelper.clone(git_url, shallow_clone, skip_docs: true)
        expect(File.directory?(result)).to eq(true)
        expect(File.exist?(File.join(result, 'README.md'))).to eq(false)
      end

      it "clones the repo" do
        path = Dir.mktmpdir # to have access to the actual path
        expect(Dir).to receive(:mktmpdir).and_return(path)
        git_url = "https://github.com/fastlane/fastlane/tree/master/certificates"
        shallow_clone = true
        command = "GIT_TERMINAL_PROMPT=0 git clone '#{git_url}' '#{path}' --depth 1 --no-single-branch"
        to_params = {
          command: command,
          print_all: nil,
          print_command: nil
        }

        expect(FastlaneCore::CommandExecutor).
          to receive(:execute).
          with(to_params).
          and_return(nil)

        result = Match::GitHelper.clone(git_url, shallow_clone)
        expect(File.directory?(result)).to eq(true)
        expect(File.exist?(File.join(result, 'README.md'))).to eq(false) # because the README is being added when committing the changes now
      end

      it "clones the repo (not shallow)" do
        path = Dir.mktmpdir # to have access to the actual path
        expect(Dir).to receive(:mktmpdir).and_return(path)
        git_url = "https://github.com/fastlane/fastlane/tree/master/certificates"
        shallow_clone = false
        command = "GIT_TERMINAL_PROMPT=0 git clone '#{git_url}' '#{path}'"
        to_params = {
          command: command,
          print_all: nil,
          print_command: nil
        }

        expect(FastlaneCore::CommandExecutor).
          to receive(:execute).
          with(to_params).
          and_return(nil)

        result = Match::GitHelper.clone(git_url, shallow_clone)
        expect(File.directory?(result)).to eq(true)
        expect(File.exist?(File.join(result, 'README.md'))).to eq(false) # because the README is being added when committing the changes now
      end

      it "checks out a branch" do
        path = Dir.mktmpdir # to have access to the actual path
        expect(Dir).to receive(:mktmpdir).and_return(path)
        git_url = "https://github.com/fastlane/fastlane/tree/master/certificates"
        git_branch = "test"
        shallow_clone = false
        command = "GIT_TERMINAL_PROMPT=0 git clone '#{git_url}' '#{path}'"
        to_params = {
          command: command,
          print_all: nil,
          print_command: nil
        }

        expect(FastlaneCore::CommandExecutor).
          to receive(:execute).
          with(to_params).
          and_return(nil)

        command = "git branch --list origin/#{git_branch} --no-color -r"
        to_params = {
          command: command,
          print_all: nil,
          print_command: nil
        }

        expect(FastlaneCore::CommandExecutor).
          to receive(:execute).
          with(to_params).
          and_return("")

        command = "git checkout --orphan #{git_branch}"
        to_params = {
          command: command,
          print_all: nil,
          print_command: nil
        }

        expect(FastlaneCore::CommandExecutor).
          to receive(:execute).
          with(to_params).
          and_return("Switched to a new branch '#{git_branch}'")

        command = "git reset --hard"
        to_params = {
          command: command,
          print_all: nil,
          print_command: nil
        }

        expect(FastlaneCore::CommandExecutor).
          to receive(:execute).
          with(to_params).
          and_return("")

        result = Match::GitHelper.clone(git_url, shallow_clone, branch: git_branch)

        expect(File.directory?(result)).to eq(true)
        expect(File.exist?(File.join(result, 'README.md'))).to eq(false) # because the README is being added when committing the changes now
      end

      after(:each) do
        Match::GitHelper.clear_changes
      end
    end
  end
end
