require 'precheck'

module Precheck
  describe Precheck do
    describe Precheck::VerifyFirebaseProjectRule do
      let(:rule) { VerifyFirebaseProjectRule.new }
      let(:minimal_xcode_project) { XcodeProjectItemToCheck.new("./spec/fixtures/MinimalApp/MinimalApp.xcodeproj", "MinimalApp", "Release", :xcode_project, "XcodeProject") }
      let(:mismatched_xcode_project) { XcodeProjectItemToCheck.new("./spec/fixtures/MismatchedApp/MismatchedApp.xcodeproj", "MismatchedApp", "Release", :xcode_project, "XcodeProject") }
      let(:good_xcode_project) { XcodeProjectItemToCheck.new("./spec/fixtures/GoodApp/GoodApp.xcodeproj", "GoodApp", "Release", :xcode_project, "XcodeProject") }
      let(:good_no_firebase_xcode_project) { XcodeProjectItemToCheck.new("./spec/fixtures/GoodAppNoFirebase/GoodAppNoFirebase.xcodeproj", "GoodAppNoFirebase", "Release", :xcode_project, "XcodeProject") }

      it "fails for missing GoogleServices-Info.plist" do
        result = rule.check_item(minimal_xcode_project)
        expect(result.status).to eq(VALIDATION_STATES[:failed])
        expect(result.failure_data).to eq("A valid Firebase project requires a GoogleService-Info.plist. Please download it via the Firebase console.")
      end

      it "fails for mismatched bundle id" do
        result = rule.check_item(mismatched_xcode_project)
        expect(result.status).to eq(VALIDATION_STATES[:failed])
        expect(result.failure_data).to eq("The project bundle id com.google.firebase.test.MismatchedApp does not match the GoogleService-Info.plist bundle id com.google.firebase.test.MinimalApp.")
      end

      it "passes for properly configured app" do
        result = rule.check_item(good_xcode_project)
        expect(result.status).to eq(VALIDATION_STATES[:passed])
      end

      it "passes for properly configured app with no Firebase pods" do
        result = rule.check_item(good_no_firebase_xcode_project)
        expect(result.status).to eq(VALIDATION_STATES[:passed])
      end
    end
  end
end
