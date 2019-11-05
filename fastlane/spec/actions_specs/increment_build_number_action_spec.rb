describe Fastlane do
  describe Fastlane::FastFile do
    describe "Increment Build Number Integration" do
      require 'shellwords'

      describe "With agv enabled" do
        before(:each) do
          allow(Fastlane::Actions::IncrementBuildNumberAction).to receive(:system).with(/agvtool/).and_return(true)
        end

        it "increments the build number of the Xcode project" do
          expect(Fastlane::Actions).to receive(:sh)
            .with(/agvtool next[-]version [-]all && cd [-]/)
            .once
            .and_return("")

          expect(Fastlane::Actions).to receive(:sh)
            .with(/agvtool what[-]version/, log: false)
            .once
            .and_return("Current version of project Test is:\n40")

          Fastlane::FastFile.new.parse("lane :test do
            increment_build_number(xcodeproj: '.xcproject')
          end").runner.execute(:test)

          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq('40')
        end

        it "pass a custom build number to the tool" do
          expect(Fastlane::Actions).to receive(:sh)
            .with(/agvtool new[-]version [-]all 24 && cd [-]/)
            .once
            .and_return("")

          result = Fastlane::FastFile.new.parse("lane :test do
            increment_build_number(build_number: 24, xcodeproj: '.xcproject')
          end").runner.execute(:test)

          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq('24')
        end

        it "displays error when $(SRCROOT) detected" do
          expect(Fastlane::Actions).to receive(:sh)
            .with(/agvtool new[-]version [-]all 24 && cd [-]/)
            .and_return("Something\n$(SRCROOT)/Test/Info.plist")

          expect(UI).to receive(:error).with('Cannot set build number with plist path containing $(SRCROOT)')
          expect(UI).to receive(:error).with('Please remove $(SRCROOT) in your Xcode target build settings')

          result = Fastlane::FastFile.new.parse("lane :test do
            increment_build_number(build_number: 24, xcodeproj: '.xcproject')
          end").runner.execute(:test)

          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq('24')
        end

        it "raises an exception when user passes workspace" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              increment_build_number(xcodeproj: 'project.xcworkspace')
            end").runner.execute(:test)
          end.to raise_error("Please pass the path to the project, not the workspace")
        end

        it "properly removes new lines of the build number" do
          expect(Fastlane::Actions).to receive(:sh)
            .with(/agvtool new[-]version [-]all 24 && cd [-]/)
            .once
            .and_return("")

          result = Fastlane::FastFile.new.parse("lane :test do
            increment_build_number(build_number: '24\n', xcodeproj: '.xcproject')
          end").runner.execute(:test)

          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq('24')
        end
      end

      describe "With agv not enabled" do
        before(:each) do
          allow(Fastlane::Actions::IncrementBuildNumberAction).to receive(:system).and_return(nil)
        end

        it "raises an exception when agv not enabled" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              increment_build_number(xcodeproj: '.xcproject')
            end").runner.execute(:test)
          end.to raise_error(/Apple Generic Versioning is not enabled./)
        end

        it "pass a custom build number to the tool" do
          expect(Fastlane::Actions).to receive(:sh)
            .with(/agvtool new[-]version [-]all 21 && cd [-]/)
            .once
            .and_return("")

          result = Fastlane::FastFile.new.parse("lane :test do
            increment_build_number(build_number: 21, xcodeproj: '.xcproject')
          end").runner.execute(:test)

          expect(result).to eq('21')
          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to eq('21')
        end
      end
    end
  end
end
