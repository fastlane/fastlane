describe Fastlane do
  describe Fastlane::FastFile do
    describe "Mercurial Push to Remote Action" do
      it "works without passing any options" do
        result = Fastlane::FastFile.new.parse("lane :test do
          hg_push
        end").runner.execute(:test)

        expect(result).to include("hg push")
      end

      it "works with options specified" do
        result = Fastlane::FastFile.new.parse("lane :test do
          hg_push(
            destination: 'https://test/owner/repo',
            force: true
          )
        end").runner.execute(:test)

        expect(result).to eq("hg push --force https://test/owner/repo")
      end
    end
  end
end
