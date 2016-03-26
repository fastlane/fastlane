module FastlaneCore
  class CrashReporting
    URL = 'https://02c6a8be5bd4425389706655f3657f5c:de62aa2bffe643948ea6f81354adb8d6@app.getsentry.com/55281'
    class << self
      def file_path
        File.expand_path(File.join('~/.fastlane_crash_reporting'))
      end

      def enable
        File.write(file_path, "1")
        puts "Successfully enabled crash reporting.".green
        puts "This will only send a stack trace for installed gems to Sentry.".green
        puts "Thanks for improving fastlane!".green
      end

      def disable
        File.delete(file_path) if File.exist?(file_path)
        puts "Disabled crash reporting :("
      end

      def enabled?
        File.exist?(file_path)
      end

      def show_message
        puts "-------------------------------------------------------------------------------------------".yellow
        puts "😨  An error occured. Please enable crash reports using `fastlane enable_crash_reporting`.".yellow
        puts "👍  This makes resolving issues much easier and helps improve fastlane.".yellow
        puts "🔒  The reports will be stored securely on getsentry.com.".yellow
        puts "🙊  More information about privacy: https://github.com/fastlane/fastlane/releases/tag/1.33.3".yellow
        puts "-------------------------------------------------------------------------------------------".yellow
      end

      # Ask the user politely if they want to send crash reports
      def ask_during_setup
        return if enabled?

        puts "-------------------------------------------------------------------------------------------".yellow
        puts "😃  Enable crash reporting when fastlane experiences a problem?".yellow
        puts "👍  This makes resolving issues much easier and helps improve fastlane.".yellow
        puts "🔒  The reports will be stored securely on getsentry.com".yellow
        puts "🙊  More information about privacy: https://github.com/fastlane/fastlane/releases/tag/1.33.3".yellow
        puts "🌴  You can always disable crash reports at anytime `fastlane disable_crash_reporting`".yellow
        puts "-------------------------------------------------------------------------------------------".yellow
        if agree("Do you want to enable crash reporting? (y/n) ", true)
          enable
        end
      end

      def handle_crash(ex)
        unless enabled?
          show_message
          return
        end

        raise ex if Helper.test?
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
        puts "Successfully submitted a crash report. If this is a problem with one of the tools specifically,".yellow
        puts "please submit an issue on GitHub and attach the following number to it: '#{crash.id}'".yellow
        puts "The crash report has been stored locally '#{path}'".yellow
      rescue => e
        UI.verbose(e) # We don't want crash reporting to cause crash
      end
    end
  end
end
