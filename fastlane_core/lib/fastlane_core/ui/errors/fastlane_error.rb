module FastlaneCore
  class FastlaneError < Interface::FastlaneException
    attr_reader :show_github_issues
    attr_reader :error_info

    def initialize(show_github_issues: false, error_info: nil)
      @show_github_issues = show_github_issues
      @error_info = error_info
    end

    def prefix
      '[USER_ERROR]'
    end

    def trimmed_backtrace
      trim_backtrace(method_name: 'user_error!')
    end

    def could_contain_pii?
      caused_by_calling_ui_method?(method_name: 'user_error!')
    end
  end
end
