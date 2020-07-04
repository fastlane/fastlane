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
          pod_push(path: './fastlane/spec/fixtures/podspecs/test.podspec', repo: 'MyRepo', swift_version: '4.0')
        end").runner.execute(:test)

        expect(result).to eq("pod repo push MyRepo './fastlane/spec/fixtures/podspecs/test.podspec' --swift-version=4.0")
      end

      it "generates the correct pod push command with a repo parameter with the allow warnings and use libraries flags" do
        result = Fastlane::FastFile.new.parse("lane :test do
          pod_push(path: './fastlane/spec/fixtures/podspecs/test.podspec', repo: 'MyRepo', allow_warnings: true, use_libraries: true)
        end").runner.execute(:test)

        expect(result).to eq("pod repo push MyRepo './fastlane/spec/fixtures/podspecs/test.podspec' --allow-warnings --use-libraries")
      end

      it "generates the correct pod push command with a repo parameter with the skip import validation and skip tests flags" do
        result = Fastlane::FastFile.new.parse("lane :test do
          pod_push(path: './fastlane/spec/fixtures/podspecs/test.podspec', repo: 'MyRepo', skip_import_validation: true, skip_tests: true)
        end").runner.execute(:test)

        expect(result).to eq("pod repo push MyRepo './fastlane/spec/fixtures/podspecs/test.podspec' --skip-import-validation --skip-tests")
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

      context "with use_bundle_exec flag" do
        context "true" do
          it "appends bundle exec at the beginning of the command" do
            result = Fastlane::FastFile.new.parse("lane :test do
              pod_push(use_bundle_exec: true)
            end").runner.execute(:test)

            expect(result).to eq("bundle exec pod trunk push")
          end
        end
        context "false" do
          it "does not appends bundle exec at the beginning of the command" do
            result = Fastlane::FastFile.new.parse("lane :test do
              pod_push(use_bundle_exec: false)
            end").runner.execute(:test)

            expect(result).to eq("pod trunk push")
          end
        end
      end

      it "generates the correct pod push command with the synchronous parameter" do
        result = Fastlane::FastFile.new.parse("lane :test do
          pod_push(synchronous: true)
        end").runner.execute(:test)

        expect(result).to eq("pod trunk push --synchronous")
      end
    end
  end
end
