require 'gym/xcodebuild_fixes/swift_fix'
require 'gym/xcodebuild_fixes/watchkit_fix'
require 'gym/xcodebuild_fixes/package_application_fix'

describe Gym do
  describe Gym::XcodebuildFixes do
    class FakePackageCommandGenerator
      attr_accessor :appfile_path
      attr_accessor :ipa_path
      def initialize(ipa_path, appfile_path)
        @ipa_path = ipa_path
        @appfile_path = appfile_path
      end
    end

    let (:ipa_with_swift) { 'gym/spec/fixtures/xcodebuild_fixes/with_swift_twice.ipa' }
    let (:ipa_without_swift) { 'gym/spec/fixtures/xcodebuild_fixes/with_no_swift.ipa' }
    let (:default_swift_libs) { 'Payload/Client.app/Frameworks/libswift.*.dylib' }
    let (:all_existing_libs) { 'libswift.*.dylib' }
    let (:non_existing_libs) { 'XXX.*.dylib' }
    let (:pcg_with_swift) { FakePackageCommandGenerator.new(ipa_with_swift, 'Payload/Client.app') }
    let (:pcg_without_swift) { FakePackageCommandGenerator.new(ipa_without_swift, 'Payload/Client.app') }

    it "finds default swift libs properly" do
      expect(Gym::XcodebuildFixes.zip_entries_matching(ipa_with_swift, /#{default_swift_libs}/).count).to eq(10)
    end

    it "finds swift libs in multiple locations" do
      expect(Gym::XcodebuildFixes.zip_entries_matching(ipa_with_swift, /#{all_existing_libs}/).count).to eq(20)
    end

    it "doesn't find swift libs without their proper path" do
      expect(Gym::XcodebuildFixes.zip_entries_matching(ipa_with_swift, /#{non_existing_libs}/).count).to eq(0)
      expect(Gym::XcodebuildFixes.zip_entries_matching(ipa_without_swift, /#{default_swift_libs}/).count).to eq(0)
    end

    it "can find directories in zips" do
      dir = 'Payload/Client.app/Frameworks/'
      expect(Gym::XcodebuildFixes.zip_entries_matching(ipa_without_swift, /#{dir}/).count).to eq(1)
    end

    it "find swift when it is there" do
      expect(Gym::XcodebuildFixes.check_for_swift(pcg_with_swift)).to eq(true)
    end

    it "doesn't find swift when it's not there" do
      expect(Gym::XcodebuildFixes.check_for_swift(pcg_without_swift)).to eq(false)
    end
  end
end
