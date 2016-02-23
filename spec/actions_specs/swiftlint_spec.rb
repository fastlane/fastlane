describe Fastlane do
  describe Fastlane::FastFile do
    describe "SwiftLint" do
      it "works" do
        result = Fastlane::FastFile.new.parse("lane :test do
          swiftlint(
            report_file: 'swiftlint.report'
          )
        end").runner.execute(:test)

        expect(result).to end_with("> swiftlint.report")
      end
    end
  end
end
