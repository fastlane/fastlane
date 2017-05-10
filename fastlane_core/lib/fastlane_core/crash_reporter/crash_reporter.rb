require 'faraday'
require 'json'

module FastlaneCore
  class CrashReporter
    def self.crash_report_path
      "#{FastlaneCore.fastlane_user_dir}/last_crash.json"
    end

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

    def self.enabled?
      true
    end

    def self.report_crash(type: :unknown, exception: nil)
      return unless enabled?
      backtrace = BacktraceSanitizer.sanitize(type: type, backtrace: exception.backtrace)
      message = report_message(type: type, exception: exception)
      payload = report_payload(message: message, backtrace: backtrace)
      send_report(payload: payload)
      UI.important("We sent a crash report to help us make _fastlane_ better!")
      save_file(payload: payload)
      UI.important("We logged a crash report to #{crash_report_path}")
    end

    private

    def self.report_message(type: :unknown, exception: nil)
      message = type == :user_error ? '' : " #{exception.message}"
      "#{types[type]}#{message}"
    end

    def self.save_file(payload: "{}")
      File.open(crash_report_path, 'w') do |f|
        f.write(payload)
      end
    end

    def self.send_report(payload: "{}")
      connection = Faraday.new(url: "https://clouderrorreporting.googleapis.com/v1beta1/projects/fastlane-166414/events:report?key=#{ENV['STACKDRIVER_API_KEY']}")
      connection.post do |request|
        request.headers['Content-Type'] = 'application/json'
        request.body = payload
      end
    end

    def self.report_payload(message: nil, backtrace: nil)
      {
        'eventTime': Time.now.to_datetime.rfc3339,
        'serviceContext': {
          'service': 'fastlane',
          'version': Fastlane::VERSION
        },
        'message': "#{message}: #{backtrace.join("\n")}",
      }.to_json
    end
  end
end
