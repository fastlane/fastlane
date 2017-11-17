require 'precheck/rule'
require 'xcodeproj'

module Precheck
  class VerifyFirebaseAuthRule < URLRule
    DETAILS_MESSAGE = "Please see https://firebase.google.com/docs/auth/ios/google-signin for details."

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
        google_service_plist = xcode_project_item.google_service_plist

        # Cannot check Auth if plist is missing
        if google_service_plist.nil?
          return RuleReturn.new(validation_state: VALIDATION_STATES[:passed])
        end

        # We need an Auth dependency to proceed
        unless xcode_project_item.podfile_includes?("Firebase/Auth")
          return RuleReturn.new(validation_state: VALIDATION_STATES[:passed])
        end

        expected_client_id = google_service_plist['REVERSED_CLIENT_ID']

        info_plist = xcode_project_item.info_plist
        # We need an Info.plist to proceed
        if info_plist.nil?
          return RuleReturn.new(validation_state: VALIDATION_STATES[:passed])
        end

        url_types = info_plist["CFBundleURLTypes"]
        if url_types.nil?
          return RuleReturn.new(validation_state: Precheck::VALIDATION_STATES[:failed], failure_data: "Your project is using Firebase/Auth but custom URL Schemes are not configured. #{DETAILS_MESSAGE}")
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

        return RuleReturn.new(validation_state: Precheck::VALIDATION_STATES[:failed], failure_data: "Your project is using Firebase/Auth but no custom URL Scheme matches #{expected_client_id}. #{DETAILS_MESSAGE}") unless matched_scheme

        return RuleReturn.new(validation_state: VALIDATION_STATES[:passed])
      }
    end
  end
end
