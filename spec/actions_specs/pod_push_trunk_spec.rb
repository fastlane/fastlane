describe Fastlane do
  describe Fastlane::FastFile do
    describe "Pod Push Trunk" do
      it "generates the correct pod push command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          pod_push_trunk
        end").runner.execute(:test)

        expect(result).to eq("pod trunk push")
      end

      it "generates the correct pod push command with an argument" do
        result = Fastlane::FastFile.new.parse("lane :test do
          pod_push_trunk(path: './fastlane/spec/fixtures/podspecs/test.podspec')
        end").runner.execute(:test)

        expect(result).to eq("pod trunk push './fastlane/spec/fixtures/podspecs/test.podspec'")
      end
    end
  end
end
