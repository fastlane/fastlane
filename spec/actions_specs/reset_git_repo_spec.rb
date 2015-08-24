describe Fastlane do
  describe Fastlane::FastFile do
    describe "reset_git_repo" do
      it "works as expected inside a Fastfile" do
        paths = Fastlane::FastFile.new.parse("lane :test do
          reset_git_repo(force: true, files: ['.'])
        end").runner.execute(:test)

        expect(paths).to eq(['.'])
      end

      it "works as expected inside a Fastfile" do
        expect do
          ff = Fastlane::FastFile.new.parse("lane :test do
            reset_git_repo
          end").runner.execute(:test)
        end.to raise_exception "This is a destructive and potentially dangerous action. To protect from data loss, please add the `ensure_git_status_clean` action to the beginning of your lane, or if you're absolutely sure of what you're doing then call this action with the :force option.".red
      end
    end
  end
end
