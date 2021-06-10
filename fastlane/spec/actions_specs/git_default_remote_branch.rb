describe Fastlane do
  describe Fastlane::FastFile do
    describe "Git Default Remote Branch Action" do
      it "generates the correct git command for retrieving default branch from remote" do
        result = Fastlane::FastFile.new.parse("lane :test do
            git_default_remote_branch
          end").runner.execute(:test)

        expect(result).to eq("variable=$(git remote) && git remote show $variable | grep \"HEAD branch\" | sed 's/.*: //'")
      end
    end
  end
end
