require 'fastlane_core'
require 'review/item_to_check'
require 'review/rule_check_result'

module Review
  VALIDATION_STATES = {
    pass: "pass",
    fail: "fail"
  }

  RULE_LEVELS = {
    warning: "warnings",
    fail: "fail",
    skip: "skip"
  }

  # Abstract super class
  attr_accessor :rule_block

  class Rule < FastlaneCore::ConfigItem
    def check_item(item)
      not_implemented(__method__)
    end

    def initialize(key: nil,
                   env_name: nil,
                   description: nil,
                   short_option: nil,
                   default_value: nil,
                   verify_block: nil,
                   is_string: nil,
                   type: nil,
                   conflicting_options: nil,
                   conflict_block: nil,
                   rule_block: nil,
                   rule_level: RULE_LEVELS[:fail],
                   deprecated: nil,
                   sensitive: nil,
                   display_in_shell: nil)
      @rule_block = rule_block
      @rule_level = rule_level

      super(key: key,
            env_name: env_name,
            description: description,
            short_option: short_option,
            default_value: default_value,
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
      @env_name
    end

    def inspect
      "#{self.class}(description: #{@description}, key: #{@key})"
    end
  end

  class TextRule < Rule
    def check_item(item)
      return nil unless @rule_level != RULE_LEVELS[:skip]
      return nil unless item.kind_of? TextItemToCheck # maybe error out here since this would be weird

      state = @rule_block.call(item.text)

      return RuleCheckResult.new(item, state, self)
    end
  end

  class URLRule < Rule
    def check_item(item)
      return nil unless @rule_level != RULE_LEVELS[:skip]
      return nil unless item.kind_of? URLItemToCheck # maybe error out here since this would be weird

      state = @rule_block.call(item.url)

      return RuleCheckResult.new(item, state, self)
    end
  end
end
