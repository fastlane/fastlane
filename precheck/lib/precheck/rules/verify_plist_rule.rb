require 'precheck/rule'

module Precheck
  class VerifyPlistRule < URLRule
    def self.key
      :verify_plist
    end

    def self.env_name
      "VERIFY_PLIST"
    end

    def self.friendly_name
      "Info.plist valid"
    end

    def self.description
      "Verifies your Info.plist contains all relevant information"
    end

    def check_item(item)
      perform_check(item: item) # we can handle anything
    end

    def rule_block
      return lambda { |something|
        plist_path = XcodeEnv.info_plist_path
        puts "Plist path: #{plist_path}"

        if plist_path.nil? || !File.exist?(plist_path)
          return RuleReturn.new(validation_state: Precheck::VALIDATION_STATES[:failed], failure_data: "Could not find Info.plist")
        end

        content = Plist.parse_xml(plist_path)
        puts "Plist content: #{content}"
        if content.count == 0
          RuleReturn.new(validation_state: Precheck::VALIDATION_STATES[:failed], failure_data: "Info.plist damanged")
        end

        # TODO: insert actual checks here

        return RuleReturn.new(validation_state: VALIDATION_STATES[:passed])
      }
    end
  end
end
