describe Fastlane do
  describe Fastlane::FastFile do
    directory = "fl_spec_default_remote_branch"

    describe "Git Remote Branch Action" do
      it "generates the correct git command for retrieving default branch from remote" do
        result = Fastlane::FastFile.new.parse("lane :test do
            git_remote_branch
          end").runner.execute(:test)

        expect(result).to eq("variable=$(git remote) && git remote show $variable | grep 'HEAD branch' | sed 's/.*: //'")
      end
    end

    describe "Git Remote Branch Action with optional remote name" do
      it "generates the correct git command for retrieving default branch using provided remote name" do
        result = Fastlane::FastFile.new.parse("lane :test do
            git_remote_branch(remote_name:'upstream')
          end").runner.execute(:test)

        expect(result).to eq("git remote show upstream | grep 'HEAD branch' | sed 's/.*: //'")
      end
    end

    context "runs the command in a directory with no git repo" do
      it "Confirms that no default remote is found" do
        test_directory_path = Dir.mktmpdir(directory)

        Dir.chdir(test_directory_path) do
          expect(Fastlane::Actions).to receive(:sh)
            .with("variable=$(git remote) && git remote show $variable | grep 'HEAD branch' | sed 's/.*: //'", log: false)

          result = Fastlane::FastFile.new.parse("lane :test do
            git_remote_branch
          end").runner.execute(:test)

          expect(result).to be_nil
        end
      end
    end

    context "runs the command in a directory with no remote git repo" do
      it "Confirms that no default remote is found" do
        test_directory_path = Dir.mktmpdir(directory)

        Dir.chdir(test_directory_path) do
          `git -c init.defaultBranch=main init`

          File.write('test_file', <<-TESTFILE)
              'Hello'
            TESTFILE
          `git add .`
          `git commit --message "Test file"`

          expect(Fastlane::Actions).to receive(:sh)
            .with("variable=$(git remote) && git remote show $variable | grep 'HEAD branch' | sed 's/.*: //'", log: false)

          result = Fastlane::FastFile.new.parse("lane :test do
            git_remote_branch
          end").runner.execute(:test)

          expect(result).to be_nil
        end
      end
    end

    context "runs the command with a remote git repo" do
      it "Confirms that a default remote is found" do
        allow(Fastlane::Actions).to receive(:sh)
          .with("variable=$(git remote) && git remote show $variable | grep 'HEAD branch' | sed 's/.*: //'", log: false)
          .and_return("main")
        allow(Fastlane::Actions).to receive(:git_branch).and_return(nil)

        result = Fastlane::FastFile.new.parse("lane :test do
            git_remote_branch
          end").runner.execute(:test)

        expect(result).to eq("main")
      end
    end

  end
end
