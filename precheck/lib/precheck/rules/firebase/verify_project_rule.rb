require 'precheck/rule'
require 'xcodeproj'

module Precheck
  class VerifyFirebaseProjectRule < URLRule
    def self.key
      :verify_project
    end

    def self.env_name
      "VERIFY_PROJECT"
    end

    def self.friendly_name
      "Xcode Project valid"
    end

    def self.description
      "Checks your Xcode Project for Firebase Compliance"
    end

    def check_item(item)
      perform_check(item: item) # we can handle anything
    end

    def full_path(project, relative_path)
      return File.join(project.path, '..', relative_path)
    end

    def rule_block
      return lambda { |xcode_project_item|
        google_service_plist = xcode_project_item.google_service_plist
        if google_service_plist.nil?
          return RuleReturn.new(validation_state: Precheck::VALIDATION_STATES[:failed], failure_data: "A valid Firebase project requires a GoogleService-Info.plist. Please download it via the Firebase console.", file_path: xcode_project_item.project_path)
        end

        target = xcode_project_item.target
        if target.nil?
          return RuleReturn.new(validation_state: Precheck::VALIDATION_STATES[:failed], failure_data: "Failed to locate a target for #{xcode_project_item.target_name}.", file_path: xcode_project_item.project_path)
        end

        build_configuration = xcode_project_item.configuration
        if build_configuration.nil?
          return RuleReturn.new(validation_state: Precheck::VALIDATION_STATES[:failed], failure_data: "Failed to locate a build configuration #{xcode_project_item.configuration} for target #{xcode_project_item.target_name}.", file_path: xcode_project_item.project_path)
        end

        infoplist_file = build_configuration.build_settings['INFOPLIST_FILE']
        if infoplist_file.nil?
          return RuleReturn.new(validation_state: Precheck::VALIDATION_STATES[:failed], failure_data: "Failed to find an INFOPLIST_FILE in a build configuration #{xcode_project_item.configuration} for target #{xcode_project_item.target_name}.", file_path: xcode_project_item.project_path)
        end

        product_bundle_identifier = build_configuration.build_settings['PRODUCT_BUNDLE_IDENTIFIER']
        if product_bundle_identifier != google_service_plist['BUNDLE_ID']
          return RuleReturn.new(validation_state: Precheck::VALIDATION_STATES[:failed], failure_data: "The project bundle id #{product_bundle_identifier} does not match the GoogleService-Info.plist bundle id #{google_service_plist['BUNDLE_ID']}.", file_path: xcode_project_item.project_path)
        end

        return RuleReturn.new(validation_state: VALIDATION_STATES[:passed])
      }
    end
  end
end
