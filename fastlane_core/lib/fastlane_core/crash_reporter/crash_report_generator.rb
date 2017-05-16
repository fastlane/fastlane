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
        backtrace = FastlaneCore::CrashReportSanitizer.sanitize_backtrace(type: type, backtrace: stack).join("\n")
        message = types[type]
        sanitized_exception_message = FastlaneCore::CrashReportSanitizer.sanitize_string(string: exception.message)
        if type == :user_error
          message += ': '
        else
          message += ": #{sanitized_exception_message}"
        end
        message = message[0..100]
        message += "\n" unless type == :user_error
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
