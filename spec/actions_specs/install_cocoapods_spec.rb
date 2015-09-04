describe Fastlane do
  describe Fastlane::FastFile do
    describe "Cocoapods Integration" do
      it "default use case" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods
        end").runner.execute(:test)

        expect(result).to eq("pod install")
      end
    end
  end
end
