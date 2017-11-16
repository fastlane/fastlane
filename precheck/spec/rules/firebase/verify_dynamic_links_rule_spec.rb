require 'precheck'

module Precheck
  describe Precheck do
    describe Precheck::VerifyFirebaseDynamicLinksRule do
      let(:rule) { VerifyFirebaseDynamicLinksRule.new }
      let(:missing_entitlements_xcode_project) { XcodeProjectItemToCheck.new("./spec/fixtures/MismatchedApp/MismatchedApp.xcodeproj", "MissingUrlSchemesApp", "Release", :xcode_project, "XcodeProject") }
      let(:incorrect_entitlements_xcode_project) { XcodeProjectItemToCheck.new("./spec/fixtures/MissingUrlSchemesApp/MissingUrlSchemesApp.xcodeproj", "MissingUrlSchemesApp", "Release", :xcode_project, "XcodeProject") }
      let(:good_xcode_project) { XcodeProjectItemToCheck.new("./spec/fixtures/GoodApp/GoodApp.xcodeproj", "GoodApp", "Release", :xcode_project, "XcodeProject") }

      it "fails for missing entitlements file" do
        result = rule.check_item(missing_entitlements_xcode_project)
        expect(result.status).to eq(VALIDATION_STATES[:failed])
        expect(result.failure_data).to eq("Your project is using Firebase Dynamic Links but you are missing the entitlements file. Please see https://firebase.google.com/docs/dynamic-links/ios/create for details.")
      end

      it "fails for missing proper associated domains" do
        result = rule.check_item(incorrect_entitlements_xcode_project)
        expect(result.status).to eq(VALIDATION_STATES[:failed])
        expect(result.failure_data).to eq("Your project is using is using Firebase Dynamic Links but none of the associated domains specifies an applink pointing to *.app.goo.gl. Please see https://firebase.google.com/docs/dynamic-links/ios/create for details.")
      end

      it "passes for properly configured app" do
        result = rule.check_item(good_xcode_project)
        expect(result.status).to eq(VALIDATION_STATES[:passed])
      end
    end
  end
end
