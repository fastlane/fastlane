describe Fastlane do
  describe Fastlane::FastFile do
    describe "Increment Build Number Integration" do
      require 'shellwords'

      it "increments the build number of the Xcode project" do
        Fastlane::FastFile.new.parse("lane :test do
          increment_build_number(xcodeproj: '.xcproject')
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to match(/cd .* && agvtool next-version -all/)
      end

      it "pass a custom build number to the tool" do
        result = Fastlane::FastFile.new.parse("lane :test do
          increment_build_number(build_number: 24, xcodeproj: '.xcproject')
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BUILD_NUMBER]).to match(/cd .* && agvtool new-version -all 24/)
      end

      it "raises an exception when use passes workspace" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            increment_build_number(xcodeproj: 'project.xcworkspace')
          end").runner.execute(:test)
        end.to raise_error("Please pass the path to the project, not the workspace".red)
      end
    end
  end
end
