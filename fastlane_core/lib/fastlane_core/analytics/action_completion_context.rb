module FastlaneCore
  class CompletionStatus
    SUCCESS = 'success'
    FAILED = 'failed'
    USER_ERROR = 'user_error'
  end

  class ActionCompletionContext < AnalyticsContext
    attr_accessor :p_hash
    attr_accessor :action_name
    attr_accessor :status
  end
end
