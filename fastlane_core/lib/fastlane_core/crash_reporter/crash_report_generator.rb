module FastlaneCore
  class CrashReportGenerator
    class << self
      def types
        {
          user_error: '[USER_ERROR]',
          crash: '[FASTLANE_CRASH]',
          exception: '[EXCEPTION]'
        }
      end

      def generate(type: :exception, exception: nil, action: nil)
        message = crash_report_message(type: type, exception: exception)
        crash_report_payload(message: message, action: action)
      end

      private

      def crash_report_message(type: :exception, exception: nil)
        return if exception.nil?
        stack = exception.respond_to?(:cleaned_backtrace) ? exception.cleaned_backtrace : exception.backtrace
        backtrace = FastlaneCore::CrashReportSanitizer.sanitize_backtrace(backtrace: stack).join("\n")
        message = exception.respond_to?(:prefix) ? exception.prefix : '[EXCEPTION]'

        if exception.respond_to?(:could_contain_pii?) && exception.could_contain_pii?
          message += ': '
        else
          sanitized_exception_message = FastlaneCore::CrashReportSanitizer.sanitize_string(string: exception.message)
          message += ": #{sanitized_exception_message}"
        end
        message = message[0..100]
        message += "\n" unless exception.respond_to?(:could_contain_pii?) && exception.could_contain_pii?
        message + backtrace
      end

      def crash_report_payload(message: '', action: nil)
        {
          'eventTime' => Time.now.utc.to_datetime.rfc3339,
          'serviceContext' => {
            'service' => action || 'fastlane',
            'version' => Fastlane::VERSION
          },
          'message' => message
        }.to_json
      end
    end
  end
end
