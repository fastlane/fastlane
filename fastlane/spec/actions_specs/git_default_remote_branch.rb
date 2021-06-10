describe Fastlane do
  describe Fastlane::FastFile do
    directory = "fl_spec_default_remote_branch"
    repository = "https://github.com/seanmcneil/Empty.git"

    describe "Git Default Remote Branch Action" do
      it "generates the correct git command for retrieving default branch from remote" do
        result = Fastlane::FastFile.new.parse("lane :test do
            git_default_remote_branch
          end").runner.execute(:test)

        expect(result).to eq("variable=$(git remote) && git remote show $variable | grep 'HEAD branch' | sed 's/.*: //'")
      end
    end

    context "runs the command in a directory with no git repo" do
      it "Confirms that no default remote is found" do
        test_directory_path = Dir.mktmpdir(directory)

        Dir.chdir(test_directory_path) do
          expect(Fastlane::Actions).to receive(:sh)
            .with("variable=$(git remote) && git remote show $variable | grep 'HEAD branch' | sed 's/.*: //'", log: false)

          result = Fastlane::FastFile.new.parse("lane :test do
            git_default_remote_branch
          end").runner.execute(:test)

          expect(result).to eq("No remote default available")
        end
      end
    end

    context "runs the command in a directory with no remote git repo" do
      it "Confirms that no default remote is found" do
        test_directory_path = Dir.mktmpdir(directory)

        Dir.chdir(test_directory_path) do
          `git init`

          File.write('test_file', <<-TESTFILE)
              'Hello'
            TESTFILE
          `git add .`
          `git commit --message "Test file"`

          expect(Fastlane::Actions).to receive(:sh)
            .with("variable=$(git remote) && git remote show $variable | grep 'HEAD branch' | sed 's/.*: //'", log: false)

          result = Fastlane::FastFile.new.parse("lane :test do
            git_default_remote_branch
          end").runner.execute(:test)

          expect(result).to eq("No remote default available")
        end
      end
    end

    context "runs the command in a directory with a remote git repo" do
      it "Confirms that a default remote is found" do
        test_directory_path = Dir.mktmpdir(directory)

        `git clone #{repository} #{test_directory_path}`

        Dir.chdir(test_directory_path) do
          expect(Fastlane::Actions).to receive(:sh)
            .with("variable=$(git remote) && git remote show $variable | grep 'HEAD branch' | sed 's/.*: //'", log: false)
            .and_return("main")

          result = Fastlane::FastFile.new.parse("lane :test do
            git_default_remote_branch
          end").runner.execute(:test)

          expect(result).to eq("main")
        end
      end
    end

    context "runs the command in a directory with a remote git repo on non-default branch" do
      it "Confirms that a default remote is found when on non-default branch" do
        test_directory_path = Dir.mktmpdir(directory)

        `git clone #{repository} #{test_directory_path}`

        Dir.chdir(test_directory_path) do
          `git checkout -b other`

          expect(Fastlane::Actions).to receive(:sh)
            .with("variable=$(git remote) && git remote show $variable | grep 'HEAD branch' | sed 's/.*: //'", log: false)
            .and_return("main")

          result = Fastlane::FastFile.new.parse("lane :test do
            git_default_remote_branch
          end").runner.execute(:test)

          expect(result).to eq("main")
        end
      end
    end

  end
end
