module Precheck
  # after each item is checked for rule conformance to a single rule, a result is generated
  # a result can have a status of success or fail for a given rule/item
  class RuleCheckResult
    attr_accessor :item
    attr_accessor :rule_return # RuleReturn
    attr_accessor :rule

    def initialize(item, rule_return, rule)
      @item = item
      @rule_return = rule_return
      @rule = rule
    end

    def status
      rule_return.validation_state
    end
  end
end
