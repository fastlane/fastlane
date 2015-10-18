module FastlaneCore
  class CrashReporting
    URL = 'https://02c6a8be5bd4425389706655f3657f5c:de62aa2bffe643948ea6f81354adb8d6@app.getsentry.com/55281'
    class << self
      def file_path
        File.expand_path(File.join('~/.fastlane_crash_reporting'))
      end

      def enable
        File.write(file_path, "1")
        puts "Successfully enabled crash reporting for future crashes".green
        puts "This will only send the stack trace the installed gems to sentry".green
        puts "Thanks for helping making fastlane better".green
      end

      def enabled?
        File.exist?(file_path)
      end

      def show_message
        puts "-------------------------------------------------------------------------------------------".yellow
        puts "😨  An error occured. Please enable crash reports using `fastlane enable_crash_reporting`".yellow
        puts "👍  This makes resolving issues much easier and helps improving fastlane".yellow
        puts "🔒  No sensitive data will be transfered when enabling crash reporting".yellow
        puts "✨  Once crash reporting is enabled, you have much cleaner output when something goes wrong".yellow
        puts "-------------------------------------------------------------------------------------------".yellow
      end

      def handle_crash(ex)
        unless enabled?
          show_message
          raise ex
          return
        end

        send_crash(ex)
      end

      def send_crash(ex)
        # https://github.com/getsentry/raven-ruby/wiki/Advanced-Configuration
        require 'raven'
        require 'json'
        require 'fastlane_core/crash_reporting/clean_stack_trace'

        Raven.configure do |config|
          config.dsn = URL
          config.logger = Logger.new('/dev/null') # we couldn't care less
          config.sanitize_fields = %w(server_name)
          config.processors << Raven::Processor::CleanStackTrace
        end

        Raven::Context.clear! # we don't want to transfer things like the host name
        crash = Raven.capture_exception(ex)
        path = "/tmp/sentry_#{crash.id}.json"
        File.write(path, JSON.pretty_generate(crash.to_hash))
        puts "Successfully submitted crash report. If you want to report this is a problem with one of the tools".yellow
        puts "please submit an issue on GitHub and attach the following number to it: '#{crash.id}'".yellow
        puts "Also stored the crash report stored locally '#{path}'".yellow
      rescue => ex
        Helper.log.debug ex # We don't want crash reporting to cause crash
      end
    end
  end
end
