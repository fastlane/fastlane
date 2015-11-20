describe Fastlane do
  describe Fastlane::FastFile do
    describe "SwiftLint" do
      it "default use case" do
        result = Fastlane::FastFile.new.parse("lane :test do
          swiftlint
        end").runner.execute(:test)

        expect(result).to eq("swiftlint")
      end
    end
  end
end
