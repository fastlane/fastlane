require 'fastlane_core'
require 'review/item_to_check'
require 'review/rule_check_result'

module Review
  VALIDATION_STATES = {
    pass: "pass",
    fail: "fail",
    skipped: "skipped"
  }

  # rules can cause warnings, errors, or be skipped all together
  # by default they are set to indicate a RULE_LEVELS[:error]
  RULE_LEVELS = {
    warning: "warnings",
    error: "error",
    skip: "skip"
  }

  # Abstract super class
  attr_accessor :rule_block

  class Rule < FastlaneCore::ConfigItem
    def initialize(short_option: nil,
                   verify_block: nil,
                   is_string: nil,
                   type: nil,
                   conflicting_options: nil,
                   conflict_block: nil,
                   rule_level: RULE_LEVELS[:error],
                   deprecated: nil,
                   sensitive: nil,
                   display_in_shell: nil)
      @rule_block = self.class.rule_block
      @rule_level = rule_level

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

    def self.rule_block
      not_implemented(__method__)
    end

    def self.default_value
      CredentialsManager::AppfileConfig.try_fetch_value(self.key)
    end

    def inspect
      "#{self.class}(description: #{@description}, key: #{@key})"
    end

    def check_item(item)
      skipped_result = return_skipped_result_if_skipped(item)
      return skipped_result unless skipped_result.nil?

      # validate the item we have was properly matched to this rule: TextItem -> TextRule, URLItem -> URLRule
      return skip_item_not_meant_for_this_rule(item) unless handle_item?(item)

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

    # by default all rules will cause a failure to be displayed on the command line
    # if the rule is skipped, we just create a RuleCheckResult that represents a skipped result
    def return_skipped_result_if_skipped(item)
      if @rule_level == RULE_LEVELS[:skip]
        return RuleCheckResult.new(item, VALIDATION_STATES[:skipped], self)
      else
        return nil
      end
    end

    def perform_check(item: nil)
      check_result = @rule_block.call(item.item_data)
      return RuleCheckResult.new(item, check_result, self)
    end
  end

  # Rule types are more or less just marker classes that are intended to communicate what types of things each rule
  # expects to deal with. TextRules deal with checking text values, URLRules will check url specific things like connectivity
  # TextRules expect that text values will be passed to the rule_block, likewise, URLs are expected to be passed to the
  # URLRule rule_block
  class TextRule < Rule
    def handle_item?(item)
      (item.kind_of? TextItemToCheck) ? true : false
    end
  end

  class URLRule < Rule
    def handle_item?(item)
      (item.kind_of? URLItemToCheck) ? true : false
    end
  end
end
