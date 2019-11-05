describe Match do
  describe Match::Storage::GitStorage do
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
      it "clones the repo" do
        path = Dir.mktmpdir # to have access to the actual path
        expect(Dir).to receive(:mktmpdir).and_return(path)
        git_url = "https://github.com/fastlane/fastlane/tree/master/certificates"
        shallow_clone = true
        command = "git clone #{git_url.shellescape} #{path.shellescape} --depth 1 --no-single-branch"
        to_params = {
          command: command,
          print_all: nil,
          print_command: nil
        }

        expect(FastlaneCore::CommandExecutor).
          to receive(:execute).
          with(to_params).
          and_return(nil)

        storage = Match::Storage::GitStorage.new(
          git_url: git_url,
          shallow_clone: shallow_clone
        )
        storage.download

        expect(File.directory?(storage.working_directory)).to eq(true)
        expect(File.exist?(File.join(storage.working_directory, 'README.md'))).to eq(false) # because the README is being added when committing the changes
      end

      it "clones the repo (not shallow)" do
        path = Dir.mktmpdir # to have access to the actual path
        expect(Dir).to receive(:mktmpdir).and_return(path)
        git_url = "https://github.com/fastlane/fastlane/tree/master/certificates"
        shallow_clone = false
        command = "git clone #{git_url.shellescape} #{path.shellescape}"
        to_params = {
          command: command,
          print_all: nil,
          print_command: nil
        }

        expect(FastlaneCore::CommandExecutor).
          to receive(:execute).
          with(to_params).
          and_return(nil)

        storage = Match::Storage::GitStorage.new(
          git_url: git_url,
          shallow_clone: shallow_clone
        )
        storage.download

        expect(File.directory?(storage.working_directory)).to eq(true)
        expect(File.exist?(File.join(storage.working_directory, 'README.md'))).to eq(false) # because the README is being added when committing the changes
      end

      it "checks out a branch" do
        path = Dir.mktmpdir # to have access to the actual path
        expect(Dir).to receive(:mktmpdir).and_return(path)
        git_url = "https://github.com/fastlane/fastlane/tree/master/certificates"
        git_branch = "test"
        shallow_clone = false

        expected_commands = [
          "git clone #{git_url.shellescape} #{path.shellescape}",
          "git --no-pager branch --list origin/#{git_branch} --no-color -r",
          "git checkout --orphan #{git_branch}",
          "git reset --hard"
        ]
        expected_commands.each do |command|
          expect(FastlaneCore::CommandExecutor).to receive(:execute).once.with({
            command: command,
            print_all: nil,
            print_command: nil
          }).and_return("")
        end

        storage = Match::Storage::GitStorage.new(
          git_url: git_url,
          shallow_clone: shallow_clone,
          branch: git_branch
        )
        storage.download

        expect(File.directory?(storage.working_directory)).to eq(true)
        expect(File.exist?(File.join(storage.working_directory, 'README.md'))).to eq(false) # because the README is being added when committing the changes
      end
    end

    describe "#save_changes" do
      it "skips README file generation if so requested" do
        path = Dir.mktmpdir # to have access to the actual path
        expect(Dir).to receive(:mktmpdir).and_return(path)
        git_url = "https://github.com/fastlane/fastlane/tree/master/certificates"
        random_file = "random_file"

        storage = Match::Storage::GitStorage.new(
          type: "appstore",
          platform: "ios",
          git_url: git_url,
          shallow_clone: false,
          skip_docs: true
        )

        expected_commands = [
          "git add #{random_file}",
          "git add match_version.txt",
          "git commit -m " + '[fastlane] Updated appstore and platform ios'.shellescape,
          "git push origin master",
          "git clone #{git_url.shellescape} #{path.shellescape}"
        ]

        expected_commands.each do |command|
          expect(FastlaneCore::CommandExecutor).to receive(:execute).once.with({
            command: command,
            print_all: nil,
            print_command: nil
          }).and_return("")
        end

        expect(storage).to receive(:clear_changes).and_return(nil) # so we can inspect the folder

        storage.download
        storage.save_changes!(files_to_commit: [random_file])

        expect(File.directory?(storage.working_directory)).to eq(true)
        expect(File.exist?(File.join(storage.working_directory, 'README.md'))).to eq(false)
        expect(File.read(File.join(storage.working_directory, 'match_version.txt'))).to eq(Fastlane::VERSION)
      end
    end
  end
end
