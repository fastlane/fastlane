
require 'fastlane/swift_fastlane_api_generator.rb'

describe Fastlane do
  describe Fastlane::SwiftFastlaneAPIGenerator do
    describe "#generate_swift" do
      it "generates swift stuff" do
        swift_generator = Fastlane::SwiftFastlaneAPIGenerator.new
        swift_generator.generate_swift
      end
    end
  end
end
