describe Fastlane do
  describe Fastlane::FastFile do
    describe "Increment Version Number Integration" do
      require 'shellwords'

      it "it increments all targets patch version number" do
        Fastlane::FastFile.new.parse("lane :test do
          increment_version_number
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to match(/cd .* && agvtool new-marketing-version 1.0.1/)
      end

      it "it increments all targets minor version number" do
        Fastlane::FastFile.new.parse("lane :test do
          increment_version_number 'minor'
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to match(/cd .* && agvtool new-marketing-version 1.1.0/)
      end

      it "it increments all targets minor version major" do
        Fastlane::FastFile.new.parse("lane :test do
          increment_version_number 'major'
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to match(/cd .* && agvtool new-marketing-version 2.0.0/)
      end

      it "pass a custom version number" do
        result = Fastlane::FastFile.new.parse("lane :test do
          increment_version_number '1.4.3'
        end").runner.execute(:test)

        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::VERSION_NUMBER]).to match(/cd .* && agvtool new-marketing-version 1.4.3/)
      end
    end
  end
end
