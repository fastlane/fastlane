module Fastlane
  # This class is used to call other actions from within actions
  # We use a separate class so that we can easily identify when
  # we have dependencies between actions
  class OtherAction
    attr_accessor :runner

    def initialize(runner)
      self.runner = runner
    end

    # Allows the user to call an action from an action
    def method_missing(method_sym, *arguments, &_block)
      self.runner.trigger_action_by_name(method_sym,
                                         File.expand_path('..', FastlaneCore::FastlaneFolder.path),
                                         true,
                                         *arguments)
    end
  end
end
