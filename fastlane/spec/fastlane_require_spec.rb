require 'fastlane/fastlane_require'

describe Fastlane do
  describe Fastlane::FastlaneRequire do
    it "formats gem require name for fastlane-plugin" do
      gem_name = "fastlane-plugin-test"
      gem_require_name = Fastlane::FastlaneRequire.format_gem_require_name(gem_name)
      expect(gem_require_name).to eq("fastlane/plugin/test")
    end

    it "formats gem require name for non-fastlane-plugin" do
      gem_name = "rest-client"
      gem_require_name = Fastlane::FastlaneRequire.format_gem_require_name(gem_name)
      expect(gem_require_name).to eq("rest-client")
    end
  end
end
