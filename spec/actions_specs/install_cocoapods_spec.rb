describe Fastlane do
  describe Fastlane::FastFile do
    describe "Cocoapods Integration" do
      it "default use case" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods
        end").runner.execute(:test)

        expect(result).to eq("pod install")
      end

      it "adds no-clean to command if clean is set to false" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(
            clean: false
          )
        end").runner.execute(:test)

        expect(result).to eq("pod install --no-clean")
      end
    end
  end
end
