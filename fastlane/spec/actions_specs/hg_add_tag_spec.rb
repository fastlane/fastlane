describe Fastlane do
  describe Fastlane::FastFile do
    describe "Mercurial Add Tag Action" do
      it "allows you to specify your own tag" do
        tag = '2.0.0'

        result = Fastlane::FastFile.new.parse("lane :test do
          hg_add_tag ({
            tag: '#{tag}',
          })
        end").runner.execute(:test)

        expect(result).to eq("hg tag \"#{tag}\"")
      end
    end
  end
end
