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

        command = "git --no-pager branch --list origin/#{git_branch} --no-color -r"
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

      it "throws error if OpenSSL versions do not match" do
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

        expect(File).
          to receive(:exist?).
          with(File.join(path, "openssl_version.txt")).
          and_return(true)
        expect(File).
          to receive(:read).
          with(File.join(path, "openssl_version.txt")).
          and_return("TooOldSSL")
        allow(Match::Encrypt).
          to receive(:openssl_version).
          and_return("OpenSSL 1.0.2k  26 Jan 2017")

        expect(UI).
          to receive(:user_error!).
          with("Repository was encrypted using 'TooOldSSL' and currently used version is 'OpenSSL 1.0.2k  26 Jan 2017'")
        Match::GitHelper.clone(git_url, shallow_clone)
      end

      after(:each) do
        Match::GitHelper.clear_changes
      end
    end

    describe "#commit_changes" do
      before(:each) do
        allow(Dir).
          to receive(:chdir).
          and_yield
        allow_any_instance_of(Module).
          to receive(:`).
          and_return("Uncommited changes exist")
        allow_any_instance_of(Match::Encrypt).to receive(:encrypt_repo)
        allow(Match::Encrypt)
          .to receive(:openssl_version)
          .and_return("OpenSSL 1.0.2k  26 Jan 2017")
        allow(File).
          to receive(:read).
          and_return("template")

        allow(File).
          to receive(:exist?).
          with("match_version.txt").
          and_return(true)
        allow(File).
          to receive(:read).
          and_return(Fastlane::VERSION.to_s)

        allow(File).
          to receive(:exist?).
          with("README.md").
          and_return(true)

        allow(FileUtils).to receive(:rm_rf)

        to_params = {
          command: "git add file1",
          print_all: nil,
          print_command: nil
        }
        expect(FastlaneCore::CommandExecutor).
          to receive(:execute).
          with(to_params)

        to_params = {
          command: "git commit -m message",
          print_all: nil,
          print_command: nil
        }
        expect(FastlaneCore::CommandExecutor).
          to receive(:execute).
          with(to_params)

        to_params = {
          command: "GIT_TERMINAL_PROMPT=0 git push origin master",
          print_all: nil,
          print_command: nil
        }
        expect(FastlaneCore::CommandExecutor).
          to receive(:execute).
          with(to_params)
      end

      it "creates openssl version file and commits it if it didn't exist" do
        expect(File).
          to receive(:exist?).
          with("openssl_version.txt").
          and_return(false)
        expect(File).
          to receive(:write).
          with("openssl_version.txt", "OpenSSL 1.0.2k  26 Jan 2017")
        to_params = {
          command: "git add openssl_version.txt",
          print_all: nil,
          print_command: nil
        }
        expect(FastlaneCore::CommandExecutor).
          to receive(:execute).
          with(to_params).
          and_return(nil)

        Match::GitHelper.commit_changes("path", "message", "git_url", "master", ["file1"])
      end

      it "updates openssl version file and commits it if version has changed" do
        expect(File).
          to receive(:exist?).
          with("openssl_version.txt").
          and_return(true)
        expect(File).
          to receive(:read).
          with("openssl_version.txt").
          and_return("TooOldSSL 0.0.1")
        expect(File).
          to receive(:write).
          with("openssl_version.txt", "OpenSSL 1.0.2k  26 Jan 2017")
        to_params = {
          command: "git add openssl_version.txt",
          print_all: nil,
          print_command: nil
        }
        expect(FastlaneCore::CommandExecutor).
          to receive(:execute).
          with(to_params).
          and_return(nil)

        Match::GitHelper.commit_changes("path", "message", "git_url", "master", ["file1"])
      end

      it "not updates openssl version file" do
        expect(File).
          to receive(:exist?).
          with("openssl_version.txt").
          and_return(true)
        expect(File).
          to receive(:read).
          with("openssl_version.txt").
          and_return("OpenSSL 1.0.2k  26 Jan 2017")
        Match::GitHelper.commit_changes("path", "message", "git_url", "master", ["file1"])
      end
    end
  end
end
