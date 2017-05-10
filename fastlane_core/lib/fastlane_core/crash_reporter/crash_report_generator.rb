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
      message = crash_report_message(type: type, exception: exception)
      crash_report_payload(message: message)
    end

    def self.crash_report_message(type: :unknown, exception: nil)
      backtrace = FastlaneCore::BacktraceSanitizer.sanitize(type: type, backtrace: exception.backtrace).join("\n")
      message = types[type]
      if type == :user_error
        message += ': '
      else
        message += ": #{exception.message}"
      end
      message = message[0..100]
      message += "\n" unless type == :user_error
      message += backtrace
    end

    def self.crash_report_payload(message: '')
      {
        'eventTime': Time.now.to_datetime.rfc3339,
        'serviceContext': {
          'service': 'fastlane',
          'version': Fastlane::VERSION
        },
        'message': message
      }.to_json
    end
  end
end