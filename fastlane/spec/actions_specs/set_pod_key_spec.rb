describe Fastlane do
  describe Fastlane::FastFile do
    describe "CocoaPods-Keys Integration" do
      it "default use case" do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        result = Fastlane::FastFile.new.parse("lane :test do
          set_pod_key(
            key: 'APIToken',
            value: '1234'
          )
        end").runner.execute(:test)

        expect(result).to eq("bundle exec pod keys set \"APIToken\" \"1234\"")
      end

      it "default use case with no bundle exec" do
        result = Fastlane::FastFile.new.parse("lane :test do
          set_pod_key(
            use_bundle_exec: false,
            key: 'APIToken',
            value: '1234'
          )
        end").runner.execute(:test)

        expect(result).to eq("pod keys set \"APIToken\" \"1234\"")
      end

      it "appends the project name when provided" do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        result = Fastlane::FastFile.new.parse("lane :test do
          set_pod_key(
            key: 'APIToken',
            value: '1234',
            project: 'MyProject'
          )
        end").runner.execute(:test)

        expect(result).to eq("bundle exec pod keys set \"APIToken\" \"1234\" \"MyProject\"")
      end

      it "requires a key" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            set_pod_key(
              value: '1234'
            )
          end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, /'key'/)
      end

      it "requires a value" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            set_pod_key(
              key: 'APIToken'
            )
          end").runner.execute(:test)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, /'value'/)
      end
    end
  end
end
