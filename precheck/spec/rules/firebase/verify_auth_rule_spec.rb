require 'precheck'

module Precheck
  describe Precheck do
    describe Precheck::VerifyFirebaseAuthRule do
      let(:rule) { VerifyFirebaseAuthRule.new }
      let(:missing_url_schemes_xcode_project) { XcodeProjectItemToCheck.new("./spec/fixtures/MissingUrlSchemesApp/MissingUrlSchemesApp.xcodeproj", "MissingUrlSchemesApp", "Release", :xcode_project, "XcodeProject") }
      let(:bad_url_schemes_xcode_project) { XcodeProjectItemToCheck.new("./spec/fixtures/BadUrlSchemesApp/BadUrlSchemesApp.xcodeproj", "BadUrlSchemesApp", "Release", :xcode_project, "XcodeProject") }
      let(:good_xcode_project) { XcodeProjectItemToCheck.new("./spec/fixtures/GoodApp/GoodApp.xcodeproj", "GoodApp", "Release", :xcode_project, "XcodeProject") }
      let(:minimal_xcode_project) { XcodeProjectItemToCheck.new("./spec/fixtures/MinimalApp/MinimalApp.xcodeproj", "MinimalApp", "Release", :xcode_project, "XcodeProject") }
      let(:good_no_firebase_xcode_project) { XcodeProjectItemToCheck.new("./spec/fixtures/GoodAppNoFirebase/GoodAppNoFirebase.xcodeproj", "GoodAppNoFirebase", "Release", :xcode_project, "XcodeProject") }

      it "fails for missing URL Schemes" do
        result = rule.check_item(missing_url_schemes_xcode_project)
        expect(result.status).to eq(VALIDATION_STATES[:failed])
        expect(result.failure_data).to eq("Your project is using Firebase/Auth but custom URL Schemes are not configured. Please see https://firebase.google.com/docs/auth/ios/google-signin for details.")
      end

      it "fails for bad URL Schemes" do
        result = rule.check_item(bad_url_schemes_xcode_project)
        expect(result.status).to eq(VALIDATION_STATES[:failed])
        expect(result.failure_data).to eq("Your project is using Firebase/Auth but no custom URL Scheme matches com.googleusercontent.apps.479288270672-bq839il215gfe2nbikv4i09s10dbnpqk. Please see https://firebase.google.com/docs/auth/ios/google-signin for details.")
      end

      it "passes for properly configured app" do
        result = rule.check_item(good_xcode_project)
        expect(result.status).to eq(VALIDATION_STATES[:passed])
      end

      it "passes for a minimal app" do
        result = rule.check_item(minimal_xcode_project)
        expect(result.status).to eq(VALIDATION_STATES[:passed])
      end

      it "passes for an app not containing auth" do
        result = rule.check_item(good_no_firebase_xcode_project)
        expect(result.status).to eq(VALIDATION_STATES[:passed])
      end
    end
  end
end
