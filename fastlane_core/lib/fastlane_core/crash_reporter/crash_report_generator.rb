module FastlaneCore
  class CrashReportGenerator
    class << self
      def generate(exception: nil, action: nil)
        message = format_crash_report_message(exception: exception)
        crash_report_payload(message: message, action: action)
      end

      private

      def format_crash_report_message(exception: nil)
        return if exception.nil?
        stack = exception.respond_to?(:trimmed_backtrace) ? exception.trimmed_backtrace : exception.backtrace
        backtrace = FastlaneCore::CrashReportSanitizer.sanitize_backtrace(backtrace: stack).join("\n")
        message = exception.respond_to?(:prefix) ? exception.prefix : '[EXCEPTION]'
        message += ': '

        if exception.respond_to?(:crash_report_message)
          message += FastlaneCore::CrashReportSanitizer.sanitize_string(string: exception.crash_report_message)
        else
          message += "#{exception.class.name}: #{FastlaneCore::CrashReportSanitizer.sanitize_string(string: exception.message)[0..100]}\n"
        end

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
