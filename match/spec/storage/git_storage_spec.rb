require_relative 'git_storage_spec_helper'

describe Match do
  describe Match::Storage::GitStorage do

    let(:git_url) { "https://github.com/fastlane/fastlane/tree/master/certificates" }
    let(:git_branch) { "test" }

    before(:each) do
      @path = Dir.mktmpdir # to have access to the actual path
      allow(Dir).to receive(:mktmpdir).and_return(@path)
    end

    describe "#generate_commit_message" do
      it "works" do
        storage = Match::Storage::GitStorage.new(
          type: "appstore",
          platform: "ios"
        )
        result = storage.generate_commit_message
        expect(result).to eq("[fastlane] Updated appstore and platform ios")
      end
    end

    describe "#download" do
      describe "when no branch is specified" do
        it "checkouts the master branch" do
          # Override default "test" branch name.
          git_branch = "master"

          storage = Match::Storage::GitStorage.new(
            git_url: git_url
          )

          clone_command = "git clone #{git_url.shellescape} #{@path.shellescape}"

          expect_command_execution(clone_command)
          expect_command_execution(branch_checkout_commands(git_branch))

          storage.download

          expect(File.directory?(storage.working_directory)).to eq(true)
          expect(File.exist?(File.join(storage.working_directory, 'README.md'))).to eq(false) # because the README is being added when committing the changes
        end
      end

      describe "when using shallow_clone" do
        it "clones the repo with correct clone command" do
          storage = Match::Storage::GitStorage.new(
            git_url: git_url,
            branch: git_branch,
            # Test case:
            shallow_clone: true
          )

          clone_command = "git clone #{git_url.shellescape} #{@path.shellescape} --depth 1 --no-single-branch"

          expect_command_execution(clone_command)
          expect_command_execution(branch_checkout_commands(git_branch))

          storage.download

          expect(File.directory?(storage.working_directory)).to eq(true)
          expect(File.exist?(File.join(storage.working_directory, 'README.md'))).to eq(false) # because the README is being added when committing the changes
        end
      end

      describe "when using shallow_clone and clone_branch_directly" do
        it "clones the repo with correct clone command" do
          storage = Match::Storage::GitStorage.new(
            git_url: git_url,
            branch: git_branch,
            # Test case:
            clone_branch_directly: true,
            shallow_clone: true
          )

          clone_command = "git clone #{git_url.shellescape} #{@path.shellescape} --depth 1 -b #{git_branch} --single-branch"

          expect_command_execution(clone_command)
          expect_command_execution(branch_checkout_commands(git_branch))

          storage.download

          expect(File.directory?(storage.working_directory)).to eq(true)
          expect(File.exist?(File.join(storage.working_directory, 'README.md'))).to eq(false) # because the README is being added when committing the changes
        end
      end

      describe "when using clone_branch_directly" do
        it "clones the repo with correct clone command" do
          storage = Match::Storage::GitStorage.new(
            git_url: git_url,
            branch: git_branch,
            # Test case:
            clone_branch_directly: true
          )

          clone_command = "git clone #{git_url.shellescape} #{@path.shellescape} -b #{git_branch} --single-branch"

          expect_command_execution(clone_command)
          expect_command_execution(branch_checkout_commands(git_branch))

          storage.download

          expect(File.directory?(storage.working_directory)).to eq(true)
          expect(File.exist?(File.join(storage.working_directory, 'README.md'))).to eq(false) # because the README is being added when committing the changes
        end
      end

      describe "when not using shallow_clone and clone_branch_directly" do
        it "clones the repo with correct clone command" do
          storage = Match::Storage::GitStorage.new(
            git_url: git_url,
            branch: git_branch,
            # Test case:
            clone_branch_directly: false,
            shallow_clone: false
          )

          clone_command = "git clone #{git_url.shellescape} #{@path.shellescape}"

          expect_command_execution(clone_command)
          expect_command_execution(branch_checkout_commands(git_branch))

          storage.download

          expect(File.directory?(storage.working_directory)).to eq(true)
          expect(File.exist?(File.join(storage.working_directory, 'README.md'))).to eq(false) # because the README is being added when committing the changes
        end
      end
    end

    describe "#save_changes" do
      describe "when skip_docs is true" do
        it "skips README file generation" do
          random_file_to_commit = "random_file_to_commit"

          storage = Match::Storage::GitStorage.new(
            type: "appstore",
            platform: "ios",
            git_url: git_url,
            branch: git_branch,
            skip_docs: true
          )

          checkout_command = "git clone #{git_url.shellescape} #{@path.shellescape}"
          expect_command_execution(checkout_command)
          expect_command_execution(branch_checkout_commands(git_branch))

          expected_commit_commands = [
            # Stage new file for commit.
            "git add #{random_file_to_commit}",
            # Stage match_version.txt for commit.
            "git add match_version.txt",
            # Commit changes.
            "git commit -m " + '[fastlane] Updated appstore and platform ios'.shellescape,
            # Push changes to the remote origin.
            "git push origin #{git_branch}"
          ]
          expect_command_execution(expected_commit_commands)

          expect(storage).to receive(:clear_changes).and_return(nil) # so we can inspect the folder

          storage.download
          storage.save_changes!(files_to_commit: [random_file_to_commit])

          expect(File.directory?(storage.working_directory)).to eq(true)
          expect(File.exist?(File.join(storage.working_directory, 'README.md'))).to eq(false)
          expect(File.read(File.join(storage.working_directory, 'match_version.txt'))).to eq(Fastlane::VERSION)
        end
      end
    end

    describe "#authentication" do
      describe "when using a private key file" do
        it "wraps the git command in ssh-agent shell" do
          expect(File).to receive(:file?).twice.and_return(true)
          private_key = "#{@path}/fastlane.match.id_dsa"
          clone_command = "ssh-agent bash -c 'ssh-add #{private_key.shellescape}; git clone #{git_url.shellescape} #{@path.shellescape}'"

          expect_command_execution(clone_command)
          expect_command_execution(branch_checkout_commands(git_branch))

          storage = Match::Storage::GitStorage.new(
            git_url: git_url,
            branch: git_branch,
            git_private_key: private_key
          )
          storage.download

          expect(File.directory?(storage.working_directory)).to eq(true)
          expect(File.exist?(File.join(storage.working_directory, 'README.md'))).to eq(false) # because the README is being added when committing the changes
        end
      end

      describe "when using a raw private key" do
        it "wraps the git command in ssh-agent shell" do
          expect(File).to receive(:file?).twice.and_return(false)
          private_key = "-----BEGIN PRIVATE KEY-----\n-----END PRIVATE KEY-----\n"
          clone_command = "ssh-agent bash -c 'ssh-add - <<< \"#{private_key}\"; git clone #{git_url.shellescape} #{@path.shellescape}'"

          expect_command_execution(clone_command)
          expect_command_execution(branch_checkout_commands(git_branch))

          storage = Match::Storage::GitStorage.new(
            git_url: git_url,
            branch: git_branch,
            git_private_key: private_key
          )
          storage.download

          expect(File.directory?(storage.working_directory)).to eq(true)
          expect(File.exist?(File.join(storage.working_directory, 'README.md'))).to eq(false) # because the README is being added when committing the changes
        end
      end
    end

    describe "#ssh-agent utilities" do
      describe "when using a raw private key" do
        it "wraps any given command in ssh-agent shell" do
          given_command = "any random command"
          private_key = "-----BEGIN PRIVATE KEY-----\n-----END PRIVATE KEY-----\n"

          storage = Match::Storage::GitStorage.new(
            git_private_key: private_key
          )

          expected_command = "ssh-agent bash -c 'ssh-add - <<< \"#{private_key}\"; #{given_command}'"
          expect(storage.command_from_private_key(given_command)).to eq(expected_command)
        end
      end

      describe "when using a private key file" do
        it "wraps any given command in ssh-agent shell" do
          given_command = "any random command"
          private_key = "#{Dir.mktmpdir}/fastlane.match.id_dsa"

          storage = Match::Storage::GitStorage.new(
            git_private_key: private_key
          )

          expected_command = "ssh-agent bash -c 'ssh-add - <<< \"#{File.expand_path(private_key).shellescape}\"; #{given_command}'"
          expect(storage.command_from_private_key(given_command)).to eq(expected_command)
        end
      end
    end
  end
end
