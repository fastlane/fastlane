describe Fastlane do
  describe Fastlane::FastFile do
    describe "git_tag_exists" do
      it "generates the correct git command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          git_tag_exists(tag: '1.2.0')
        end").runner.execute(:test)

        expect(result).to eq('git rev-parse -q --verify "refs/tags/1.2.0" || true')
      end
    end
  end
end
