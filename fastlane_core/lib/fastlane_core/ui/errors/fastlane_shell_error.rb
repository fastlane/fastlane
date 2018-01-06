require_relative 'fastlane_exception'

module FastlaneCore
  class Interface
    class FastlaneShellError < FastlaneException
      def prefix
        '[SHELL_ERROR]'
      end

      def trimmed_backtrace
        backtrace = trim_backtrace(method_name: 'shell_error!')

        # we also want to trim off the shell invocation itself, which means
        # removing any lines from the backtrace that contain functions
        # in `sh_helper.rb`
        backtrace.drop_while { |frame| frame.include?('sh_helper.rb') }
      end

      def could_contain_pii?
        caused_by_calling_ui_method?(method_name: 'shell_error!')
      end
    end
  end
end
