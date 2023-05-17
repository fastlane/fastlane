describe Fastlane do
  describe Fastlane::FastFile do
    describe "ensure_git_status_clean" do
      before :each do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        allow(FastlaneCore::UI).to receive(:success).with("Driving the lane 'test' 🚀")
      end

      context "when git status is clean" do
        before :each do
          allow(Fastlane::Actions).to receive(:sh).with("git status --porcelain", log: true).and_return("")
        end

        it "outputs success message" do
          expect(FastlaneCore::UI).to receive(:success).with("Git status is clean, all good! 💪")
          Fastlane::FastFile.new.parse("lane :test do
            ensure_git_status_clean
          end").runner.execute(:test)
        end
      end

      context "when git status is not clean" do
        before :each do
          allow(Fastlane::Actions).to receive(:sh).with("git status --porcelain", log: true).and_return("M fastlane/lib/fastlane/actions/ensure_git_status_clean.rb")
          allow(Fastlane::Actions).to receive(:sh).with("git status --porcelain", log: false).and_return("M fastlane/lib/fastlane/actions/ensure_git_status_clean.rb")
          allow(Fastlane::Actions).to receive(:sh).with("git status --porcelain --ignored='traditional'", log: true).and_return("M fastlane/lib/fastlane/actions/ensure_git_status_clean.rb\n!! .DS_Store\n!! fastlane/")
          allow(Fastlane::Actions).to receive(:sh).with("git status --porcelain --ignored='no'", log: true).and_return("M fastlane/lib/fastlane/actions/ensure_git_status_clean.rb")
          allow(Fastlane::Actions).to receive(:sh).with("git status --porcelain --ignored='matching'", log: true).and_return("M fastlane/lib/fastlane/actions/ensure_git_status_clean.rb\n!! .DS_Store\n!! fastlane/.DS_Store")
          allow(Fastlane::Actions).to receive(:sh).with("git diff").and_return("+ \"this is a new line\"")
        end

        context "with ignore_files" do
          it "outputs success message" do
            expect(FastlaneCore::UI).to receive(:success).with("Git status is clean, all good! 💪")
            Fastlane::FastFile.new.parse("lane :test do
              ensure_git_status_clean(
                ignore_files: ['fastlane/lib/fastlane/actions/ensure_git_status_clean.rb']
              )
            end").runner.execute(:test)
          end

          it "outputs rich error message" do
            expect(FastlaneCore::UI).to receive(:user_error!).with("Git repository is dirty! Please ensure the repo is in a clean state by committing/stashing/discarding all changes first.")
            Fastlane::FastFile.new.parse("lane :test do
              ensure_git_status_clean(
                ignore_files: ['.DS_Store']
              )
            end").runner.execute(:test)
          end
        end

        context "with show_uncommitted_changes flag" do
          context "true" do
            it "outputs rich error message" do
              expect(FastlaneCore::UI).to receive(:user_error!).with("Git repository is dirty! Please ensure the repo is in a clean state by committing/stashing/discarding all changes first.\nUncommitted changes:\nM fastlane/lib/fastlane/actions/ensure_git_status_clean.rb")
              Fastlane::FastFile.new.parse("lane :test do
                ensure_git_status_clean(show_uncommitted_changes: true)
              end").runner.execute(:test)
            end
          end

          context "false" do
            it "outputs short error message" do
              expect(FastlaneCore::UI).to receive(:user_error!).with("Git repository is dirty! Please ensure the repo is in a clean state by committing/stashing/discarding all changes first.")
              Fastlane::FastFile.new.parse("lane :test do
                ensure_git_status_clean(show_uncommitted_changes: false)
              end").runner.execute(:test)
            end
          end
        end

        context "without show_uncommitted_changes flag" do
          it "outputs short error message" do
            expect(FastlaneCore::UI).to receive(:user_error!).with("Git repository is dirty! Please ensure the repo is in a clean state by committing/stashing/discarding all changes first.")
            Fastlane::FastFile.new.parse("lane :test do
              ensure_git_status_clean
            end").runner.execute(:test)
          end
        end

        context "with show_diff flag" do
          context "true" do
            it "outputs rich error message" do
              expect(FastlaneCore::UI).to receive(:user_error!).with("Git repository is dirty! Please ensure the repo is in a clean state by committing/stashing/discarding all changes first.\nGit diff: \n+ \"this is a new line\"")
              Fastlane::FastFile.new.parse("lane :test do
                ensure_git_status_clean(show_diff: true)
              end").runner.execute(:test)
            end
          end

          context "false" do
            it "outputs short error message" do
              expect(FastlaneCore::UI).to receive(:user_error!).with("Git repository is dirty! Please ensure the repo is in a clean state by committing/stashing/discarding all changes first.")
              Fastlane::FastFile.new.parse("lane :test do
                ensure_git_status_clean(show_diff: false)
              end").runner.execute(:test)
            end
          end
        end

        context "with ignored mode" do
          context "traditional" do
            it "outputs error message with ignored files" do
              expect(FastlaneCore::UI).to receive(:user_error!).with("Git repository is dirty! Please ensure the repo is in a clean state by committing/stashing/discarding all changes first.\nUncommitted changes:\nM fastlane/lib/fastlane/actions/ensure_git_status_clean.rb\n!! .DS_Store\n!! fastlane/")
              Fastlane::FastFile.new.parse("lane :test do
                ensure_git_status_clean(show_uncommitted_changes: true, ignored: 'traditional')
              end").runner.execute(:test)
            end
          end

          context "none" do
            it "outputs error message without ignored files" do
              expect(FastlaneCore::UI).to receive(:user_error!).with("Git repository is dirty! Please ensure the repo is in a clean state by committing/stashing/discarding all changes first.\nUncommitted changes:\nM fastlane/lib/fastlane/actions/ensure_git_status_clean.rb")
              Fastlane::FastFile.new.parse("lane :test do
                ensure_git_status_clean(show_uncommitted_changes: true, ignored: 'none')
              end").runner.execute(:test)
            end
          end

          context "matching" do
            it "outputs error message with ignored files" do
              expect(FastlaneCore::UI).to receive(:user_error!).with("Git repository is dirty! Please ensure the repo is in a clean state by committing/stashing/discarding all changes first.\nUncommitted changes:\nM fastlane/lib/fastlane/actions/ensure_git_status_clean.rb\n!! .DS_Store\n!! fastlane/.DS_Store")
              Fastlane::FastFile.new.parse("lane :test do
                ensure_git_status_clean(show_uncommitted_changes: true, ignored: 'matching')
              end").runner.execute(:test)
            end
          end
        end

        context "without ignored mode" do
          it "outputs error message without ignored files" do
            expect(FastlaneCore::UI).to receive(:user_error!).with("Git repository is dirty! Please ensure the repo is in a clean state by committing/stashing/discarding all changes first.\nUncommitted changes:\nM fastlane/lib/fastlane/actions/ensure_git_status_clean.rb")
            Fastlane::FastFile.new.parse("lane :test do
              ensure_git_status_clean(show_uncommitted_changes: true)
            end").runner.execute(:test)
          end
        end
      end
    end
  end
end
