require 'json'

require_relative '../env'
require_relative '../helper'
require_relative '../globals'
require_relative '../ui/ui'
require_relative 'crash_report_generator'

module FastlaneCore
  class CrashReporter
    class << self
      @did_report_crash = false

      @explicitly_enabled_for_testing = false

      def crash_report_path
        File.join(FastlaneCore.fastlane_user_dir, 'latest_crash.json')
      end

      def enabled?
        !FastlaneCore::Env.truthy?("FASTLANE_OPT_OUT_CRASH_REPORTING")
      end

      def report_crash(exception: nil)
        return unless enabled?
        return if @did_report_crash
        return if exception.fastlane_crash_came_from_custom_action?

        # Do not run the crash reporter while tests are happening (it might try to send
        # a crash report), unless we have explicitly turned on the crash reporter because
        # we want to test it
        return if Helper.test? && !@explicitly_enabled_for_testing
        begin
          payload = CrashReportGenerator.generate(exception: exception)
          send_report(payload: payload)
          save_file(payload: payload)
          show_message unless did_show_message?
          @did_report_crash = true
        rescue
          if FastlaneCore::Globals.verbose?
            UI.error("Unable to send the crash report.")
            UI.error("Please open an issue on GitHub if you need help!")
          end
        end
      end

      def reset_crash_reporter_for_testing
        @did_report_crash = false
      end

      def enable_for_testing
        @explicitly_enabled_for_testing = true
      end

      def disable_for_testing
        @explicitly_enabled_for_testing = false
      end

      private

      def show_message
        UI.message("Sending crash report...")
        UI.message("The stack trace is sanitized so no personal information is sent.")
        UI.message("To see what we are sending, look here: #{crash_report_path}")
        UI.message("Learn more at https://docs.fastlane.tools/actions/opt_out_crash_reporting/")
        UI.message("You can disable crash reporting by adding `opt_out_crash_reporting` at the top of your Fastfile")
      end

      def did_show_message?
        file_name = ".did_show_opt_out_crash_info"

        path = File.join(FastlaneCore.fastlane_user_dir, file_name)
        did_show = File.exist?(path)

        return did_show if did_show

        begin
          File.write(path, '1')
        rescue
          if FastlaneCore::Globals.verbose?
            UI.error("Cannot write out file indicating that crash report announcement has been displayed.")
            UI.error("The following message will be displayed on the next crash as well:")
          end
        end
        false
      end

      def save_file(payload: "{}")
        File.write(crash_report_path, payload)
      rescue
        UI.message("fastlane failed to write the crash report to #{crash_report_path}.")
      end

      def send_report(payload: "{}")
        require 'faraday'
        connection = Faraday.new(url: "https://clouderrorreporting.googleapis.com/v1beta1/projects/fastlane-166414/events:report?key=AIzaSyAMACPfuI-wi4grJWEZjcPvhfV2Rhmddwo")
        connection.post do |request|
          request.headers['Content-Type'] = 'application/json'
          request.body = payload
        end
      end
    end
  end
end
