require "stringio"

describe Fastlane::Actions do
  describe "#lanespechelper" do
    describe "current_platform" do
      it "no platform" do
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::PLATFORM_NAME] = nil
        expect(Fastlane::Helper::LaneHelper.current_platform).to eq(nil)
      end

      it "ios platform" do
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::PLATFORM_NAME] = :ios
        expect(Fastlane::Helper::LaneHelper.current_platform).to eq(:ios)

        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::PLATFORM_NAME] = nil
      end

      it "android platform" do
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::PLATFORM_NAME] = :android
        expect(Fastlane::Helper::LaneHelper.current_platform).to eq(:android)

        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::PLATFORM_NAME] = nil
      end
    end

    describe "current_lane" do
      it "no lane" do
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME] = nil
        expect(Fastlane::Helper::LaneHelper.current_lane).to eq(nil)
      end

      it "test" do
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME] = :test
        expect(Fastlane::Helper::LaneHelper.current_lane).to eq(:test)

        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME] = nil
      end
    end
  end
end
