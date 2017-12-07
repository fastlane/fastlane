module FastlaneCore
  class ActionCompletionStatus
    SUCCESS = 'success'
    FAILED = 'failed' # fastlane crashes unrelated to user_error!
    USER_ERROR = 'user_error' # Anytime a user_error! is triggered
    INTERRUPTED = 'interrupted'
  end

  class ActionCompletionContext
    attr_accessor :p_hash
    attr_accessor :app_id
    attr_accessor :action_name
    attr_accessor :status

    def initialize(app_id: nil, p_hash: nil, action_name: nil, status: nil)
      @app_id = app_id
      @p_hash = p_hash
      @action_name = action_name
      @status = status
    end

    def self.context_for_action_name(action_name, args: nil, status: nil)
      app_id_guesser = FastlaneCore::AppIdentifierGuesser.new(args: args)
      return self.new(
        action_name: action_name,
        app_id: app_id_guesser.app_id,
        p_hash: app_id_guesser.p_hash,
        status: status
      )
    end
  end
end
