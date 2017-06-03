module Review
  # after each item is checked for rule conformance to a single rule, a result is generated
  # a result can have a status of success or fail for a given rule/item
  class RuleCheckResult
    attr_accessor :item
    attr_accessor :status # REVIEW: :VALIDATION_STATES
    attr_accessor :rule

    def initialize(item, status, rule)
      @item = item
      @status = status
      @rule = rule
    end
  end
end
