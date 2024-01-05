require 'credentials_manager/appfile_config'
require 'fastlane_core/configuration/config_item'

require_relative 'module'
require_relative 'item_to_check'
require_relative 'rule_check_result'

module Precheck
  VALIDATION_STATES = {
    passed: "passed",
    failed: "failed"
  }

  # rules can cause warnings, errors, or be skipped all together
  # by default they are set to indicate a RULE_LEVELS[:error]
  RULE_LEVELS = {
    warn: :warn,
    error: :error,
    skip: :skip
  }

  # Abstract super class
  attr_accessor :rule_block

  class Rule < FastlaneCore::ConfigItem
    # when a rule evaluates a single item, it has a validation state
    # if it fails, it has some data like what text failed to pass, or maybe a bad url
    # this class encapsulates that return value and state
    # it is the return value from each evaluated @rule_block
    class RuleReturn
      attr_accessor :validation_state
      attr_accessor :failure_data

      def initialize(validation_state: nil, failure_data: nil)
        @validation_state = validation_state
        @failure_data = failure_data
      end
    end

    def initialize(short_option: nil,
                   verify_block: nil,
                   is_string: nil,
                   type: nil,
                   conflicting_options: nil,
                   conflict_block: nil,
                   deprecated: nil,
                   sensitive: nil,
                   display_in_shell: nil)

      super(key: self.class.key,
            env_name: self.class.env_name,
            description: self.class.description,
            short_option: short_option,
            default_value: self.class.default_value,
            verify_block: verify_block,
            is_string: is_string,
            type: type,
            optional: true,
            conflicting_options: conflicting_options,
            conflict_block: conflict_block,
            deprecated: deprecated,
            sensitive: sensitive,
            display_in_shell: display_in_shell)
    end

    def to_s
      @key
    end

    def self.env_name
      not_implemented(__method__)
    end

    def self.key
      not_implemented(__method__)
    end

    def self.description
      not_implemented(__method__)
    end

    def self.friendly_name
      not_implemented(__method__)
    end

    def self.default_value
      CredentialsManager::AppfileConfig.try_fetch_value(self.key)
    end

    def friendly_name
      return self.class.friendly_name
    end

    def inspect
      "#{self.class}(description: #{@description}, key: #{@key})"
    end

    # some rules can be customized with extra data at runtime, see CustomTextRule as an example
    def needs_customization?
      return false
    end

    # some rules can be customized with extra data at runtime, see CustomTextRule as an example
    def customize_with_data(data: nil)
      not_implemented(__method__)
    end

    # some rules only support specific fields, by default, all fields are supported unless restricted by
    # providing a list of symbols matching the item_name as defined as the ItemToCheck is generated
    def supported_fields_symbol_set
      return nil
    end

    def rule_block
      not_implemented(__method__)
    end

    def check_item(item)
      # validate the item we have was properly matched to this rule: TextItem -> TextRule, URLItem -> URLRule
      return skip_item_not_meant_for_this_rule(item) unless handle_item?(item)
      return skip_item_not_meant_for_this_rule(item) unless item_field_supported?(item_name: item.item_name)

      # do the actual checking now
      return perform_check(item: item)
    end

    def skip_item_not_meant_for_this_rule(item)
      # item isn't mean for this rule, which is fine, we can just keep passing it along
      return nil
    end

    # each rule can define what type of ItemToCheck subclass they support
    # override this method and return true or false
    def handle_item?(item)
      not_implemented(__method__)
    end

    def item_field_supported?(item_name: nil)
      return true if supported_fields_symbol_set.nil?
      return true if supported_fields_symbol_set.include?(item_name)
      return false
    end

    def perform_check(item: nil)
      if item.item_data.to_s == "" && item.is_optional
        # item is optional, and empty, so that's totally fine
        check_result = RuleReturn.new(validation_state: VALIDATION_STATES[:passed])
        return RuleCheckResult.new(item, check_result, self)
      end

      check_result = self.rule_block.call(item.item_data)
      return RuleCheckResult.new(item, check_result, self)
    end
  end

  # Rule types are more or less just marker classes that are intended to communicate what types of things each rule
  # expects to deal with. TextRules deal with checking text values, URLRules will check url specific things like connectivity
  # TextRules expect that text values will be passed to the rule_block, likewise, URLs are expected to be passed to the
  # URLRule rule_block
  class TextRule < Rule
    def handle_item?(item)
      item.kind_of?(TextItemToCheck) ? true : false
    end
  end

  class URLRule < Rule
    def handle_item?(item)
      item.kind_of?(URLItemToCheck) ? true : false
    end
  end
end
