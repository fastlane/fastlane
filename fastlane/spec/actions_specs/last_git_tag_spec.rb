describe Fastlane do
  describe Fastlane::FastFile do
    describe "last_git_tag" do
      it "Returns the last git tag" do
        result = Fastlane::FastFile.new.parse("lane :test do
          last_git_tag
        end").runner.execute(:test)

        tag_name = %w(git rev-list --tags --max-count=1).shelljoin
        describe = %W(git describe --tags #{tag_name}).shelljoin
        expect(result).to eq(describe)
      end

      it "Returns nothing for jibberish tag pattern match" do
        tag_pattern = "jibberish"
        result = Fastlane::FastFile.new.parse("lane :test do
          last_git_tag(pattern: \"#{tag_pattern}\")
        end").runner.execute(:test)

        tag_name = %W(git rev-list --tags=#{tag_pattern} --max-count=1).shelljoin
        describe = %W(git describe --tags #{tag_name}).shelljoin
        expect(result).to eq(describe)
      end
    end
  end
end
