describe Fastlane do
  describe Fastlane::FastFile do
    describe "Pod Push action" do
      it "generates the correct pod push command with no parameters" do
        result = Fastlane::FastFile.new.parse("lane :test do
          pod_push
        end").runner.execute(:test)

        expect(result).to eq("pod trunk push")
      end

      it "generates the correct pod push command with a path parameter" do
        result = Fastlane::FastFile.new.parse("lane :test do
          pod_push(path: './fastlane/spec/fixtures/podspecs/test.podspec')
        end").runner.execute(:test)

        expect(result).to eq("pod trunk push './fastlane/spec/fixtures/podspecs/test.podspec'")
      end

      it "generates the correct pod push command with a repo parameter" do
        result = Fastlane::FastFile.new.parse("lane :test do
          pod_push(path: './fastlane/spec/fixtures/podspecs/test.podspec', repo: 'MyRepo')
        end").runner.execute(:test)

        expect(result).to eq("pod repo push MyRepo './fastlane/spec/fixtures/podspecs/test.podspec'")
      end
    end
  end
end
