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

      it "adds no-integrate to command if integrate is set to false" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(
            integrate: false
          )
        end").runner.execute(:test)

        expect(result).to eq("pod install --no-integrate")
      end

      it "adds no-repo-update to command if repo_update is set to false" do
        result = Fastlane::FastFile.new.parse("lane :test do
          cocoapods(
            repo_update: false
          )
        end").runner.execute(:test)

        expect(result).to eq("pod install --no-repo-update")
      end
    end
  end
end
