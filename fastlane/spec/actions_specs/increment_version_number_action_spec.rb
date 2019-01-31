describe Fastlane do
  describe Fastlane::FastFile do
    describe "Increment Version Number Integration" do
      it "it increments all targets patch version number" do
        expect(Fastlane::Actions).to receive(:sh)
          .with(/agvtool what-marketing-version/, any_args)
          .once
          .and_return("1.0.0")
        Fastlane::FastFile.new.parse("lane :test do
          increment_version_number
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to match(/cd .* && agvtool new-marketing-version 1.0.1/)
      end

      it "it increments all targets minor version number" do
        expect(Fastlane::Actions).to receive(:sh)
          .with(/agvtool what-marketing-version/, any_args)
          .once
          .and_return("1.0.0")
        Fastlane::FastFile.new.parse("lane :test do
          increment_version_number(bump_type: 'minor')
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to match(/cd .* && agvtool new-marketing-version 1.1.0/)
      end

      it "it increments all targets minor version major" do
        expect(Fastlane::Actions).to receive(:sh)
          .with(/agvtool what-marketing-version/, any_args)
          .once
          .and_return("1.0.0")
        Fastlane::FastFile.new.parse("lane :test do
          increment_version_number(bump_type: 'major')
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to match(/cd .* && agvtool new-marketing-version 2.0.0/)
      end

      it "pass a custom version number" do
        result = Fastlane::FastFile.new.parse("lane :test do
          increment_version_number(version_number: '1.4.3')
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to match(/cd .* && agvtool new-marketing-version 1.4.3/)
      end

      it "prefers a custom version number over a boring version bump" do
        Fastlane::FastFile.new.parse("lane :test do
          increment_version_number(version_number: '1.77.3', bump_type: 'major')
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to match(/cd .* && agvtool new-marketing-version 1.77.3/)
      end

      it "automatically removes new lines from the version number" do
        Fastlane::FastFile.new.parse("lane :test do
          increment_version_number(version_number: '1.77.3\n', bump_type: 'major')
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to end_with("&& agvtool new-marketing-version 1.77.3")
      end

      it "returns the new version as return value" do
        expect(Fastlane::Actions).to receive(:sh)
          .with(/agvtool what-marketing-version/, any_args)
          .once
          .and_return("1.0.0")
        result = Fastlane::FastFile.new.parse("lane :test do
          increment_version_number(bump_type: 'major')
        end").runner.execute(:test)

        expect(result).to eq(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER])
      end

      it "raises an exception when xcode project path wasn't found" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            increment_version_number(xcodeproj: '/nothere')
          end").runner.execute(:test)
        end.to raise_error("Could not find Xcode project")
      end

      it "raises an exception when user passes workspace" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            increment_version_number(xcodeproj: 'project.xcworkspace')
          end").runner.execute(:test)
        end.to raise_error("Please pass the path to the project, not the workspace")
      end

      it "raises an exception when unable to calculate new version" do
        expect(Fastlane::Actions).to receive(:sh)
          .with(/agvtool what-marketing-version/, any_args)
          .once
          .and_return("00000")
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            increment_version_number
          end").runner.execute(:test)
        end.to raise_error("Your current version (00000) does not respect the format A.B.C")
      end
    end
  end
end
