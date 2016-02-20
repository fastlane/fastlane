describe Fastlane do
  describe Fastlane::FastFile do
    describe "Git Pull Action" do
      it "runs git pull and git fetch with tags by default" do
        result = Fastlane::FastFile.new.parse("lane :test do
            git_pull
          end").runner.execute(:test)

        expect(result).to eq("git pull && git fetch --tags")
      end

      it "only runs git fetch --tags if only_tags" do
        result = Fastlane::FastFile.new.parse("lane :test do
            git_pull(
              only_tags: true
            )
          end").runner.execute(:test)

        expect(result).to eq("git fetch --tags")
      end
    end
  end
end
