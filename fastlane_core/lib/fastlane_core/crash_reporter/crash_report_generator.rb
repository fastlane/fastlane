module FastlaneCore
  class CrashReportGenerator

    def self.types
      {
        user_error: '[USER_ERROR]',
        crash: '[FASTLANE_CRASH]',
        connection_failure: '[CONNECTION_FAILURE]',
        system: '[SYSTEM_ERROR]',
        option_parser: '[OPTION_PARSER]',
        invalid_command: '[INVALID_COMMAND]',
        unknown: '[UNKNOWN]'
      }
    end

    def self.generate(type: :unknown, exception: nil)
      backtrace = FastlaneCore::BacktraceSanitizer.sanitize(type: type, backtrace: exception.backtrace)

      message = crash_report_message(type: type, exception: exception)

      crash_report_payload(message: message, backtrace: backtrace)
    end

    def self.crash_report_message(type: :unknown, exception: nil)
      message = type == :user_error ? '' : " #{exception.message}"
      "#{types[type]}#{message}"
    end

    def self.crash_report_payload(message: nil, backtrace: nil)
      {
        'eventTime': Time.now.to_datetime.rfc3339,
        'serviceContext': {
          'service': 'fastlane',
          'version': Fastlane::VERSION
        },
        'message': "#{message}:\n#{backtrace.join("\n")}",
      }.to_json
    end
  end
end