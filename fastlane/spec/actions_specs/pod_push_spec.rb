describe Fastlane do
  describe Fastlane::FastFile do
    describe "Pod Push action" do
      before :each do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
      end

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

      it "generates the correct pod push command with a repo parameter with the swift version flag" do
        result = Fastlane::FastFile.new.parse("lane :test do
          pod_push(path: './fastlane/spec/fixtures/podspecs/test.podspec', repo: 'MyRepo', swift_version: 4.0)
        end").runner.execute(:test)

        expect(result).to eq("pod repo push MyRepo './fastlane/spec/fixtures/podspecs/test.podspec' --swift-version=4.0")
      end

      it "generates the correct pod push command with a repo parameter with the allow warnings and use libraries flags" do
        result = Fastlane::FastFile.new.parse("lane :test do
          pod_push(path: './fastlane/spec/fixtures/podspecs/test.podspec', repo: 'MyRepo', allow_warnings: true, use_libraries: true)
        end").runner.execute(:test)

        expect(result).to eq("pod repo push MyRepo './fastlane/spec/fixtures/podspecs/test.podspec' --allow-warnings --use-libraries")
      end

      it "generates the correct pod push command with a json file" do
        result = Fastlane::FastFile.new.parse("lane :test do
          pod_push(path: './fastlane/spec/fixtures/podspecs/test.podspec.json', repo: 'MyRepo')
        end").runner.execute(:test)

        expect(result).to eq("pod repo push MyRepo './fastlane/spec/fixtures/podspecs/test.podspec.json'")
      end

      it "errors if the path file does not end with .podspec or .podspec.json" do
        ff = Fastlane::FastFile.new.parse("lane :test do
          pod_push(path: './fastlane/spec/fixtures/podspecs/test.notpodspec')
        end")

        expect do
          ff.runner.execute(:test)
        end.to raise_error("File must be a `.podspec` or `.podspec.json`")
      end
    end
  end
end
