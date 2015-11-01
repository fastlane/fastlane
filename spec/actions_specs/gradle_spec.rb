describe Fastlane do
  describe Fastlane::FastFile do
    describe "gradle" do
      it "generates a valid command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          gradle(task: 'test', gradle_path: './fastlane/README.md')
        end").runner.execute(:test)

        expect(result).to eq("./fastlane/README.md test ")
      end
    end
  end
end
