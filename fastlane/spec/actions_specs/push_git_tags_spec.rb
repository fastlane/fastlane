describe Fastlane do
  describe Fastlane::FastFile do
    describe "push_git_tags" do
      it "uses the correct default comand" do
        result = Fastlane::FastFile.new.parse("lane :test do
          push_git_tags
        end").runner.execute(:test)

        expect(result).to eq("git push --tags")
      end

      it "uses the correct comand when forced" do
        result = Fastlane::FastFile.new.parse("lane :test do
          push_git_tags(force: true)
        end").runner.execute(:test)

        expect(result).to eq("git push --tags --force")
      end

      it "uses the correct comand when remote set" do
        result = Fastlane::FastFile.new.parse("lane :test do
          push_git_tags(remote: 'foo')
        end").runner.execute(:test)

        expect(result).to eq("git push --tags foo")
      end

      it "uses the correct comand when remote set and forced" do
        result = Fastlane::FastFile.new.parse("lane :test do
          push_git_tags(remote: 'foo', force: true)
        end").runner.execute(:test)

        expect(result).to eq("git push --tags --force foo")
      end
    end
  end
end
