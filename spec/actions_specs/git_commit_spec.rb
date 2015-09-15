describe Fastlane do
  describe Fastlane::FastFile do
    describe "git_commit" do
      it "generates the correct git command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          git_commit(path: './README.md', message: 'message')
        end").runner.execute(:test)

        expect(result).to eq("git commit -m 'message' './README.md'")
      end
    end
  end
end
