require_relative 'app_identifier_guesser'

module FastlaneCore
  class ActionCompletionStatus
    SUCCESS = 'success'
    FAILED = 'failed' # fastlane crashes unrelated to user_error!
    USER_ERROR = 'user_error' # Anytime a user_error! is triggered
    INTERRUPTED = 'interrupted'
  end

  class ActionCompletionContext
    attr_accessor :p_hash
    attr_accessor :action_name
    attr_accessor :status

    def initialize(p_hash: nil, action_name: nil, status: nil)
      @p_hash = p_hash
      @action_name = action_name
      @status = status
    end

    def self.context_for_action_name(action_name, args: nil, status: nil)
      app_id_guesser = FastlaneCore::AppIdentifierGuesser.new(args: args)
      return self.new(
        action_name: action_name,
        p_hash: app_id_guesser.p_hash,
        status: status
      )
    end
  end
end
