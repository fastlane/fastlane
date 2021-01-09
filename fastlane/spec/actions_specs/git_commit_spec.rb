describe Fastlane do
  describe Fastlane::FastFile do
    describe "git_commit" do
      before :each do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
      end

      it "generates the correct git command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          git_commit(path: './fastlane/README.md', message: 'message')
        end").runner.execute(:test)

        expect(result).to eq("git commit -m message ./fastlane/README.md")
      end

      it "generates the correct git command with an array of paths" do
        result = Fastlane::FastFile.new.parse("lane :test do
          git_commit(path: ['./fastlane/README.md', './LICENSE'], message: 'message')
        end").runner.execute(:test)

        expect(result).to eq("git commit -m message ./fastlane/README.md ./LICENSE")
      end

      it "generates the correct git command with an array of paths and/or pathspecs" do
        result = Fastlane::FastFile.new.parse("lane :test do
          git_commit(path: ['./fastlane/*.md', './LICENSE'], message: 'message')
        end").runner.execute(:test)

        expect(result).to eq("git commit -m message #{'./fastlane/*.md'.shellescape} ./LICENSE")
      end

      it "generates the correct git command with shell-escaped-paths" do
        result = Fastlane::FastFile.new.parse("lane :test do
          git_commit(path: ['./fastlane/README.md', './LICENSE', './fastlane/spec/fixtures/git_commit/A FILE WITH SPACE'], message: 'message')
        end").runner.execute(:test)

        expect(result).to eq("git commit -m message ./fastlane/README.md ./LICENSE " + "./fastlane/spec/fixtures/git_commit/A FILE WITH SPACE".shellescape)
      end

      it "generates the correct git command with a shell-escaped message" do
        message = "message with 'quotes' (and parens)"
        result = Fastlane::FastFile.new.parse("lane :test do
          git_commit(path: './fastlane/README.md', message: \"#{message}\")
        end").runner.execute(:test)
        expect(result).to eq("git commit -m #{message.shellescape} ./fastlane/README.md")
      end

      it "generates the correct git command when configured to skip git hooks" do
        result = Fastlane::FastFile.new.parse("lane :test do
          git_commit(path: './fastlane/README.md', message: 'message', skip_git_hooks: true)
        end").runner.execute(:test)

        expect(result).to eq("git commit -m message ./fastlane/README.md --no-verify")
      end

      it "generates the correct git command when configured to allow nothing to commit and there are changes to commit" do
        result = Fastlane::FastFile.new.parse("lane :test do
          git_commit(path: './fastlane/README.md', message: 'message', allow_nothing_to_commit: true)
        end").runner.execute(:test)

        expect(result).to eq("git commit -m message ./fastlane/README.md")
      end

      it "does not generate the git command when configured to allow nothing to commit and there are no changes to commit" do
        allow(Fastlane::Actions).to receive(:sh)
          .with("git --no-pager diff --name-only --staged")
          .and_return("")
        result = Fastlane::FastFile.new.parse("lane :test do
          git_commit(path: './fastlane/README.md', message: 'message', allow_nothing_to_commit: true)
        end").runner.execute(:test)

        expect(result).to be_nil
      end
    end
  end
end
