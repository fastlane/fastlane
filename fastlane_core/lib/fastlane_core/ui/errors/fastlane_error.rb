require_relative 'fastlane_exception'

module FastlaneCore
  class Interface
    class FastlaneError < FastlaneException
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
end

class Exception
  def fastlane_crash_came_from_custom_action?
    custom_frame = exception && exception.backtrace && exception.backtrace.find { |frame| frame.start_with?('actions/') }
    !custom_frame.nil?
  end

  def fastlane_crash_came_from_plugin?
    plugin_frame = exception && exception.backtrace && exception.backtrace.find { |frame| frame.include?('fastlane-plugin-') }
    !plugin_frame.nil?
  end

  def fastlane_should_report_metrics?
    if fastlane_crash_came_from_plugin? || fastlane_crash_came_from_custom_action?
      false
    else
      true
    end
  end
end
