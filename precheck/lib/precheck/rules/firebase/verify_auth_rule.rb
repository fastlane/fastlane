require 'precheck/rule'
require 'xcodeproj'

module Precheck
  class VerifyFirebaseAuthRule < URLRule
    @@details_message = "Please see https://firebase.google.com/docs/auth/ios/google-signin for details."

    def self.key
      :verify_firebase_auth
    end

    def self.env_name
      "VERIFY_FIREBASE_AUTH"
    end

    def self.friendly_name
      "Firebase Auth is valid or not in use"
    end

    def self.description
      "Checks if Firebase Authentication is properly configured"
    end

    def check_item(item)
      perform_check(item: item)
    end

    def rule_block
      return lambda { |xcode_project_item|

        google_service_plist = xcode_project_item.get_google_service_plist()

        # Cannot check Auth if plist is missing
        if google_service_plist.nil?
          return RuleReturn.new(validation_state: VALIDATION_STATES[:passed])
        end

        podfile = xcode_project_item.get_podfile()
        # Cannot check Auth if Podfile is missing
        if podfile.nil?
          return RuleReturn.new(validation_state: VALIDATION_STATES[:passed])
        end

        auth_dependency = podfile.dependencies.detect { |dep| dep.name == 'Firebase/Auth' }

        # We need an Auth dependency to proceed
        if auth_dependency.nil?
          return RuleReturn.new(validation_state: VALIDATION_STATES[:passed])
        end

        expected_client_id = google_service_plist['REVERSED_CLIENT_ID']

        info_plist = xcode_project_item.get_info_plist()
        # We need an Info.plist to proceed
        if info_plist.nil?
          return RuleReturn.new(validation_state: VALIDATION_STATES[:passed])
        end

        url_types = info_plist["CFBundleURLTypes"]
        if url_types.nil?
          return RuleReturn.new(validation_state: Precheck::VALIDATION_STATES[:failed], failure_data: "Your project is using Firebase/Auth but custom URL Schemes are not configured. #{@@details_message}")
        end

        matched_scheme = false

        url_types.each do |url_type|
          url_schemes = url_type["CFBundleURLSchemes"]
          url_schemes.each do |url_scheme|
            if url_scheme == expected_client_id
              matched_scheme = true
            end
          end
        end

        return RuleReturn.new(validation_state: Precheck::VALIDATION_STATES[:failed], failure_data: "Your project is using Firebase/Auth but no custom URL Scheme matches #{expected_client_id}. #{@@details_message}") unless matched_scheme

        return RuleReturn.new(validation_state: VALIDATION_STATES[:passed])
      }
    end
  end
end
