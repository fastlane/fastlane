require 'fastlane/lane_list'

describe Fastlane do
  describe Fastlane::LaneList do
    it "#generate" do
      result = Fastlane::LaneList.generate('./spec/fixtures/fastfiles/FastfileGrouped')

      expect(result).to include("fastlane ios beta")
      expect(result).to include("This will **not** submit the app for review")
      expect(result).to include("general")
    end
  end
end
