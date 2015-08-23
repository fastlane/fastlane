describe Fastlane do
  describe Fastlane::FastFile do
    describe "push_git_tags" do
      it "uses the correct comand" do
        result = Fastlane::FastFile.new.parse("lane :test do
          push_git_tags
        end").runner.execute(:test)

        expect(result).to eq("git push --tags")
      end
    end
  end
end
