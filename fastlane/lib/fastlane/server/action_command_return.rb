module Fastlane
  # Encapsulates the result and description of a return object returned by an executed fastlane action
  class ActionCommandReturn
    attr_reader :return_value
    attr_reader :return_value_type
    attr_reader :closure_argument_value

    def initialize(return_value: nil, return_value_type: nil, closure_argument_value: nil)
      @return_value = return_value
      @closure_argument_value = closure_argument_value
      @return_value_type = return_value_type
    end
  end
end
