describe Match do
  describe Match::GitHelper do
    let :git_url do
      git_bare = Git.init(Dir.mktmpdir, bare: true)
      git_bare.repo.to_s
    end

    let :git_url_with_test_branch do
      git_bare = Git.init(Dir.mktmpdir, bare: true)
      git = Git.clone(git_bare.repo.to_s, ".", {path: Dir.mktmpdir})
      git.checkout(["--orphan", "test"])
      git.commit("initial commit", allow_empty: true)
      git.push(:origin, "test")
      git_bare.repo.to_s
    end

    after do
      FileUtils.rm_rf(git_url)
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
        shallow_clone = false
        result = Match::GitHelper.clone(git_url, shallow_clone, skip_docs: true)
        expect(File.directory?(result)).to eq(true)
        expect(File.exist?(File.join(result, 'README.md'))).to eq(false)
      end

      it "clones the repo" do
        shallow_clone = false
        result = Match::GitHelper.clone(git_url, shallow_clone)
        expect(File.directory?(result)).to eq(true)
        expect(File.exist?(File.join(result, 'README.md'))).to eq(true)
      end

      it "clones the repo (not shallow)" do
        shallow_clone = false
        result = Match::GitHelper.clone(git_url, shallow_clone)
        expect(File.directory?(result)).to eq(true)
        expect(File.exist?(File.join(result, 'README.md'))).to eq(true)
      end

      it "checks out a new branch" do
        shallow_clone = false
        git_branch = "test"
        result = Match::GitHelper.clone(git_url, shallow_clone, branch: git_branch)
        expect(File.directory?(result)).to eq(true)
        expect(File.exist?(File.join(result, 'README.md'))).to eq(true)
        expect(Git.open(result).current_branch).to eq(git_branch)
      end

      it "checks out an existing branch" do
        shallow_clone = false
        git_branch = "test"
        result = Match::GitHelper.clone(git_url_with_test_branch, shallow_clone, branch: git_branch)
        expect(File.directory?(result)).to eq(true)
        expect(File.exist?(File.join(result, 'README.md'))).to eq(true)
        expect(Git.open(result).current_branch).to eq(git_branch)
      end

      after(:each) do
        Match::GitHelper.clear_changes
      end
    end

    describe "commit_changes" do
      it "works" do
        path = Match::GitHelper.clone(git_url, false, skip_docs: false)
        Match::GitHelper.commit_changes(path, "test commit", git_url)
      end
    end
  end
end
