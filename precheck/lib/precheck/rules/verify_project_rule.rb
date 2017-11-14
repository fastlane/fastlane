require 'precheck/rule'
require 'xcodeproj'

module Precheck
  class VerifyProjectRule < URLRule
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

    def rule_block
      return lambda { |project_path|
        puts "Project path: #{project_path}"

        project = Xcodeproj::Project.open(project_path)

        google_service_plist_entry = project.files.select{|x| x.path == 'GoogleService-Info.plist'}[0]
        if google_service_plist_entry.nil?
          return RuleReturn.new(validation_state: Precheck::VALIDATION_STATES[:failed], failure_data: "A valid Firebase project requires a GoogleService-Info.plist. Please download it via the Firebase console.")
        end


        google_service_plist = Xcodeproj::Plist.read_from_path(GetFullPath(project, google_service_plist_entry.path))
        puts 'REVERSED_CLIENT_ID: ' + google_service_plist['REVERSED_CLIENT_ID']


        return RuleReturn.new(validation_state: VALIDATION_STATES[:passed])
      }
    end
  end
end
