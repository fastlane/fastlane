require 'faraday'
require 'json'

module FastlaneCore
  class CrashReporter
    class << self
      def crash_report_path
        "#{FastlaneCore.fastlane_user_dir}/last_crash.json"
      end

      def enabled?
        !FastlaneCore::Env.truthy?("FASTLANE_OPT_OUT_CRASH_REPORTING")
      end

      def report_crash(type: :unknown, exception: nil)
        return unless enabled?
        payload = CrashReportGenerator.generate(type: type, exception: exception)
        send_report(payload: payload)
        save_file(payload: payload)
        show_message unless did_show_message?
      end

      private

      def show_message
        UI.message("Sending crash report...")
        UI.message("The stacktrace is sanitized so no personal information is sent.")
        UI.message("To see what we are sending, look here: #{crash_report_path}")
        UI.message("Learn more at https://github.com/fastlane/fastlane#crash-reporting")
        UI.message("You can disable crash reporting by adding `opt_out_crash_reporting` at the top of your Fastfile")
      end

      def did_show_message?
        file_name = ".did_show_opt_out_crash_info"

        path = File.join(FastlaneCore.fastlane_user_dir, file_name)
        did_show = File.exist?(path)

        return did_show if did_show

        File.write(path, '1')
        false
      end

      def save_file(payload: "{}")
        File.open(crash_report_path, 'w') do |f|
          f.write(payload)
        end
      end

      def send_report(payload: "{}")
        connection = Faraday.new(url: "https://clouderrorreporting.googleapis.com/v1beta1/projects/fastlane-166414/events:report?key=AIzaSyAMACPfuI-wi4grJWEZjcPvhfV2Rhmddwo")
        connection.post do |request|
          request.headers['Content-Type'] = 'application/json'
          request.body = payload
        end
      end
    end
  end
end
