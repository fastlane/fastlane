describe Fastlane do
  describe Fastlane::FastFile do
    describe "Get Version Number Integration" do
      require 'shellwords'

      it "gets the version number of the Xcode project" do
        Fastlane::FastFile.new.parse("lane :test do
          get_version_number(xcodeproj: '.xcproject')
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to match(/cd .* && agvtool what-marketing-version -terse1/)
      end

      it "raises an exception when use passes workspace" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            get_version_number(xcodeproj: 'project.xcworkspace')
          end").runner.execute(:test)
        end.to raise_error("Please pass the path to the project, not the workspace".red)
      end
    end
  end
end
