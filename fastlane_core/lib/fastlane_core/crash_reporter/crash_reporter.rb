require 'faraday'
require 'json'

module FastlaneCore
  class CrashReporter
    def self.crash_report_path
      "#{FastlaneCore.fastlane_user_dir}/last_crash.json"
    end

    def self.enabled?
      true
    end

    def self.report_crash(type: :unknown, exception: nil)
      return unless enabled?
      payload = CrashReportGenerator.generate(type: type, exception: exception)
      send_report(payload: payload)
      UI.important("We sent a crash report to help us make _fastlane_ better!")
      save_file(payload: payload)
      UI.important("We logged a crash report to #{crash_report_path}")
    end

    private

    def self.save_file(payload: "{}")
      File.open(crash_report_path, 'w') do |f|
        f.write(payload)
      end
    end

    def self.send_report(payload: "{}")
      connection = Faraday.new(url: "https://clouderrorreporting.googleapis.com/v1beta1/projects/fastlane-166414/events:report?key=AIzaSyAMACPfuI-wi4grJWEZjcPvhfV2Rhmddwo")
      connection.post do |request|
        request.headers['Content-Type'] = 'application/json'
        request.body = payload
      end
    end
  end
end
