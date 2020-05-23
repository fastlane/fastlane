describe Fastlane::Actions::EnsureXcodeVersionAction do
  describe "matching versions" do
    describe "strictly with minor version 8.0" do
      let(:different_response) { "Xcode 7.3\nBuild version 34a893" }
      let(:matching_response) { "Xcode 8.0\nBuild version 8A218a" }
      let(:matching_response_extra_output) { "Couldn't verify that spaceship is up to date\nXcode 8.0\nBuild version 8A218a" }

      it "is successful when the version matches" do
        expect(Fastlane::Actions::EnsureXcodeVersionAction).to receive(:sh).and_return(matching_response)
        expect(UI).to receive(:success).with(/Driving the lane/)
        expect(UI).to receive(:success).with(/Selected Xcode version is correct/)

        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_xcode_version(version: '8.0')
        end").runner.execute(:test)
      end

      it "matches even when there is extra output" do
        expect(Fastlane::Actions::EnsureXcodeVersionAction).to receive(:sh).and_return(matching_response_extra_output)
        expect(UI).to receive(:success).with(/Driving the lane/)
        expect(UI).to receive(:success).with(/Selected Xcode version is correct/)

        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_xcode_version(version: '8.0')
        end").runner.execute(:test)
      end

      it "presents an error when the version does not match" do
        expect(Fastlane::Actions::EnsureXcodeVersionAction).to receive(:sh).and_return(different_response)
        expect(UI).to receive(:user_error!).with("Selected Xcode version doesn't match your requirement.\nExpected: Xcode 8.0\nActual: Xcode 7.3\n")

        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_xcode_version(version: '8.0')
        end").runner.execute(:test)
      end

      it "properly compares versions, not just strings" do
        expect(Fastlane::Actions::EnsureXcodeVersionAction).to receive(:sh).and_return(matching_response)
        expect(UI).to receive(:success).with(/Driving the lane/)
        expect(UI).to receive(:success).with(/Selected Xcode version is correct/)

        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_xcode_version(version: '8')
        end").runner.execute(:test)
      end

      describe "loads a .xcode-version file if it exists" do
        let(:xcode_version_path) { ".xcode-version" }
        before do
          expect(Fastlane::Actions::EnsureXcodeVersionAction).to receive(:sh).and_return(matching_response)
          expect(Dir).to receive(:glob).with(".xcode-version").and_return([xcode_version_path])
        end

        it "succeeds if the numbers match" do
          expect(UI).to receive(:success).with(/Driving the lane/)
          expect(UI).to receive(:success).with(/Selected Xcode version is correct/)

          expect(File).to receive(:read).with(xcode_version_path).and_return("8.0")

          result = Fastlane::FastFile.new.parse("lane :test do
            ensure_xcode_version
          end").runner.execute(:test)
        end

        it "fails if the numbers don't match" do
          expect(UI).to receive(:user_error!).with("Selected Xcode version doesn't match your requirement.\nExpected: Xcode 9.0\nActual: Xcode 8.0\n")

          expect(File).to receive(:read).with(xcode_version_path).and_return("9.0")

          result = Fastlane::FastFile.new.parse("lane :test do
            ensure_xcode_version
          end").runner.execute(:test)
        end
      end
    end

    describe "strictly with patch version 8.0.1" do
      let(:different_response) { "Xcode 7.3\nBuild version 34a893" }
      let(:matching_response) { "Xcode 8.0.1\nBuild version 8A218a" }
      let(:matching_response_extra_output) { "Couldn't verify that spaceship is up to date\nXcode 8.0.1\nBuild version 8A218a" }

      it "is successful when the version matches" do
        expect(Fastlane::Actions::EnsureXcodeVersionAction).to receive(:sh).and_return(matching_response)
        expect(UI).to receive(:success).with(/Driving the lane/)
        expect(UI).to receive(:success).with(/Selected Xcode version is correct/)

        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_xcode_version(version: '8.0.1')
        end").runner.execute(:test)
      end

      it "matches even when there is extra output" do
        expect(Fastlane::Actions::EnsureXcodeVersionAction).to receive(:sh).and_return(matching_response_extra_output)
        expect(UI).to receive(:success).with(/Driving the lane/)
        expect(UI).to receive(:success).with(/Selected Xcode version is correct/)

        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_xcode_version(version: '8.0.1')
        end").runner.execute(:test)
      end

      it "presents an error when the version does not match" do
        expect(Fastlane::Actions::EnsureXcodeVersionAction).to receive(:sh).and_return(different_response)
        expect(UI).to receive(:user_error!).with("Selected Xcode version doesn't match your requirement.\nExpected: Xcode 8.0\nActual: Xcode 7.3\n")

        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_xcode_version(version: '8.0')
        end").runner.execute(:test)
      end
    end

    describe "loosely with 8.1.2" do
      let(:different_response) { "Xcode 7.3\nBuild version 34a893" }
      let(:matching_response) { "Xcode 8.1.2\nBuild version 8A218a" }
      let(:matching_response_extra_output) { "Couldn't verify that spaceship is up to date\nXcode 8.1.2\nBuild version 8A218a" }

      it "is successful when the version matches with patch" do
        expect(Fastlane::Actions::EnsureXcodeVersionAction).to receive(:sh).and_return(matching_response)
        expect(UI).to receive(:success).with(/Driving the lane/)
        expect(UI).to receive(:success).with(/Selected Xcode version is correct/)

        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_xcode_version(version: '8.1.2', strict: false)
        end").runner.execute(:test)
      end

      it "is successful when the version matches with minor" do
        expect(Fastlane::Actions::EnsureXcodeVersionAction).to receive(:sh).and_return(matching_response)
        expect(UI).to receive(:success).with(/Driving the lane/)
        expect(UI).to receive(:success).with(/Selected Xcode version is correct/)

        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_xcode_version(version: '8.1', strict: false)
        end").runner.execute(:test)
      end

      it "is successful when the version matches with major" do
        expect(Fastlane::Actions::EnsureXcodeVersionAction).to receive(:sh).and_return(matching_response)
        expect(UI).to receive(:success).with(/Driving the lane/)
        expect(UI).to receive(:success).with(/Selected Xcode version is correct/)

        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_xcode_version(version: '8', strict: false)
        end").runner.execute(:test)
      end

      it "matches even when there is extra output" do
        expect(Fastlane::Actions::EnsureXcodeVersionAction).to receive(:sh).and_return(matching_response_extra_output)
        expect(UI).to receive(:success).with(/Driving the lane/)
        expect(UI).to receive(:success).with(/Selected Xcode version is correct/)

        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_xcode_version(version: '8.1', strict: false)
        end").runner.execute(:test)
      end

      it "presents an error when the version does not match" do
        expect(Fastlane::Actions::EnsureXcodeVersionAction).to receive(:sh).and_return(different_response)
        expect(UI).to receive(:user_error!).with("Selected Xcode version doesn't match your requirement.\nExpected: Xcode 8.0\nActual: Xcode 7.3\n")

        result = Fastlane::FastFile.new.parse("lane :test do
          ensure_xcode_version(version: '8.0')
        end").runner.execute(:test)
      end
    end
  end
end
