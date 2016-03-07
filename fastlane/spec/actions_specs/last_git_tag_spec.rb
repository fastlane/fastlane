describe Fastlane do
  describe Fastlane::FastFile do
    describe "last_git_tag" do
      it "Returns the last git tag" do
        result = Fastlane::FastFile.new.parse("lane :test do
          last_git_tag
        end").runner.execute(:test)

        expect(result).to eq("git describe --tags `git rev-list --tags --max-count=1`")
      end
    end
  end
end
