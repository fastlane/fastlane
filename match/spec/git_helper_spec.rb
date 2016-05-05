describe Match do
  describe Match::GitHelper do
    before do
      @git_url = Dir.mktmpdir
      Git.init(@git_url, bare: true)

      # Create initial commit
      tmp_dir = Dir.mktmpdir
      tmp_git = Git.clone(@git_url, ".", path: tmp_dir)
      tmp_git.commit("initial commit", allow_empty: true)
      tmp_git.push(:origin, :master)
      $dir = @git_url
    end

    after do
      FileUtils.rm_rf(@git_url)
    end

    describe "generate_commit_message" do
      it "works" do
        values = {
          app_identifier: "tools.fastlane.app",
          type: "appstore"
        }
        result = Match::GitHelper.generate_commit_message(values)
        expect(result).to eq("[fastlane] Updated tools.fastlane.app for appstore")
      end
    end

    describe "#clone" do
      it "skips README file generation if so requested" do
        path = Dir.mktmpdir # to have access to the actual path
        expect(Dir).to receive(:mktmpdir).and_return(path)
        shallow_clone = false
        result = Match::GitHelper.clone(@git_url, shallow_clone, skip_docs: true)
        expect(File.directory?(result)).to eq(true)
        expect(File.exist?(File.join(result, 'README.md'))).to eq(false)
      end

      it "clones the repo" do
        shallow_clone = false
        result = Match::GitHelper.clone(@git_url, shallow_clone)
        expect(File.directory?(result)).to eq(true)
        expect(File.exist?(File.join(result, 'README.md'))).to eq(true)
      end

      it "clones the repo (not shallow)" do
        shallow_clone = false
        result = Match::GitHelper.clone(@git_url, shallow_clone)
        expect(File.directory?(result)).to eq(true)
        expect(File.exist?(File.join(result, 'README.md'))).to eq(true)
      end

      after(:each) do
        Match::GitHelper.clear_changes
      end
    end

    describe "commit_changes" do
      it "works" do
        path = Match::GitHelper.clone(@git_url, false, skip_docs: false)
        Match::GitHelper.commit_changes(path, "test commit", @git_url)
      end
    end
  end
end
