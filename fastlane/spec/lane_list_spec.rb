require 'fastlane/lane_list'

describe Fastlane do
  describe Fastlane::LaneList do
    it "#generate" do
      result = Fastlane::LaneList.generate('./fastlane/spec/fixtures/fastfiles/FastfileGrouped')

      expect(result).to include("fastlane ios beta")
      expect(result).to include("Build and upload a new build to Apple")
      expect(result).to include("general")
    end

    it "#generate_json" do
      result = Fastlane::LaneList.generate_json('./fastlane/spec/fixtures/fastfiles/FastfileGrouped')
      expect(result).to eq({
        nil => {
          test: { description: "Run all the tests" },
          anotherroot: { description: "" }
 },
        :mac => {
          beta: { description: "Build and upload a new build to Apple TestFlight\nThis action will also do a build version bump and push it to git.\nThis will **not** send an email to all testers, it will only be uploaded to the new TestFlight." }
 },
        :ios => {
          beta: { description: "Submit a new version to the App Store" },
          release: { description: "" }
 },
        :android => {
          beta: { description: "Upload something to Google" },
          witherror: { description: "" },
          unsupported_action: { description: "" }
 }
 })
    end

    it "generates empty JSON if there is no Fastfile" do
      result = Fastlane::LaneList.generate_json(nil)
      expect(result).to eq({})
    end

    describe "#lane_name_from_swift_line" do
      let(:testLane) { "func testLane() {" }
      let(:testLaneWithOptions) { "func testLane(withOptions: [String: String]?) {" }
      let(:testNoLane) { "func test() {" }
      let(:testNoLaneWithOptions) { "func test(withOptions: [String: String]?) {" }

      it "finds lane name without options" do
        name = Fastlane::LaneList.lane_name_from_swift_line(potential_lane_line: testLane)
        expect(name).to eq("testLane")
      end

      it "finds lane name with options" do
        name = Fastlane::LaneList.lane_name_from_swift_line(potential_lane_line: testLaneWithOptions)
        expect(name).to eq("testLane")
      end

      it "doesn't find lane name without options" do
        name = Fastlane::LaneList.lane_name_from_swift_line(potential_lane_line: testNoLane)
        expect(name).to eq(nil)
      end

      it "doesn't find lane name with options" do
        name = Fastlane::LaneList.lane_name_from_swift_line(potential_lane_line: testNoLaneWithOptions)
        expect(name).to eq(nil)
      end
    end
  end
end
