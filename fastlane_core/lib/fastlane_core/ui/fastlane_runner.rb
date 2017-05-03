unless Object.const_defined?("Faraday")
  # We create these empty error classes if we didn't require Faraday
  # so that we can use it in the rescue block below even if we didn't
  # require Faraday or didn't use it
  module Faraday
    class Error < StandardError; end
    class ClientError < Error; end
    class SSLError < ClientError; end
    class ConnectionFailed < ClientError; end
  end
end

module Commander
  # This class override the run method with our custom stack trace handling
  # In particular we want to distinguish between user_error! and crash! (one with, one without stack trace)
  class Runner
    # Code taken from https://github.com/commander-rb/commander/blob/master/lib/commander/runner.rb#L50
    def run!
      require_program :version, :description
      trap('INT') { abort program(:int_message) } if program(:int_message)
      trap('INT') { program(:int_block).call } if program(:int_block)
      global_option('-h', '--help', 'Display help documentation') do
        args = @args - %w(-h --help)
        command(:help).run(*args)
        return
      end
      global_option('-v', '--version', 'Display version information') do
        say version
        return
      end
      parse_global_options
      remove_global_options options, @args

      collector = FastlaneCore::ToolCollector.new

      begin
        collector.did_launch_action(@program[:name])
        # PILOT_MAINTENANCE Temporaroy `begin/rescue` block for pilot mainenance mode
        begin
          run_active_command
        rescue => e
          raise e unless @program[:name] == 'pilot'
          raise_pilot_maintenance_mode_exception!(e)
        end
      rescue InvalidCommandError => e
        # calling `abort` makes it likely that tests stop without failing, so
        # we'll disable that during tests.
        if FastlaneCore::Helper.test?
          raise e
        else
          FastlaneCore::CrashReporter.report_crash(type: :invalid_command, exception: e)
          abort "#{e}. Use --help for more information"
        end
      rescue Interrupt => e
        # We catch it so that the stack trace is hidden by default when using ctrl + c
        if FastlaneCore::Globals.verbose?
          raise e
        else
          puts "\nCancelled... use --verbose to show the stack trace"
        end
      rescue \
        OptionParser::InvalidOption,
        OptionParser::InvalidArgument,
        OptionParser::MissingArgument => e
        # calling `abort` makes it likely that tests stop without failing, so
        # we'll disable that during tests.
        if FastlaneCore::Helper.test?
          raise e
        else
          FastlaneCore::CrashReporter.report_crash(type: :option_parser, exception: e)
          abort e.to_s
        end
      rescue FastlaneCore::Interface::FastlaneError => e # user_error!
        collector.did_raise_error(@program[:name])
        show_github_issues(e.message) if e.show_github_issues
        FastlaneCore::CrashReporter.report_crash(type: :user_error, exception: e)
        display_user_error!(e, e.message)
      rescue Errno::ENOENT => e
        # We're also printing the new-lines, as otherwise the message is not very visible in-between the error and the stacktrace
        puts ""
        FastlaneCore::UI.important("Error accessing file, this might be due to fastlane's directory handling")
        FastlaneCore::UI.important("Check out https://docs.fastlane.tools/advanced/#directory-behavior for more details")
        puts ""
        FastlaneCore::CrashReporter.report_crash(type: :system, exception: e)
        raise e
      rescue FastlaneCore::Interface::FastlaneTestFailure => e # test_failure!
        display_user_error!(e, e.to_s)
      rescue Faraday::SSLError => e # SSL issues are very common
        handle_ssl_error!(e)
      rescue Faraday::ConnectionFailed => e
        if e.message.include? 'Connection reset by peer - SSL_connect'
          handle_tls_error!(e)
        else
          FastlaneCore::CrashReporter.report_crash(type: :connection_failure, exception: e)
          handle_unknown_error!(e)
        end
      rescue => e # high chance this is actually FastlaneCore::Interface::FastlaneCrash, but can be anything else
        FastlaneCore::CrashReporter.report_crash(type: :crash, exception: e)
        collector.did_crash(@program[:name])
        handle_unknown_error!(e)
      ensure
        collector.did_finish
      end
    end

    # PILOT_MAINTENANCE Remove after pilot migration is done
    def raise_pilot_maintenance_mode_exception!(e)
      FastlaneCore::UI.important("-------------")
      FastlaneCore::UI.important("pilot crashed")
      FastlaneCore::UI.important("-------------")
      FastlaneCore::UI.error("Unfortunately the TestFlight update from 11th April 2017 changed")
      FastlaneCore::UI.error("the way Testers, Groups, and Builds are managed on iTunesConnect.")
      FastlaneCore::UI.error("We have already fixed a number of features including submitting")
      FastlaneCore::UI.error("builds for testing, adding and removing testers from groups, and")
      FastlaneCore::UI.error("waiting for builds to process.")
      FastlaneCore::UI.error("")
      FastlaneCore::UI.error("Please open an issue on https://github.com/fastlane/fastlane/issues")
      FastlaneCore::UI.error("if you believe this failure is the result of a bug in _pilot_ and we")
      FastlaneCore::UI.error("will be happy to look into this further.")
      FastlaneCore::UI.error("")
      FastlaneCore::UI.error("Please stay tuned for more updates from _fastlane_ as we fix more issues!")
      FastlaneCore::UI.error("")
      if FastlaneCore::Globals.verbose?
        raise e # on verbose mode, we want to show the original stack trace
      else
        FastlaneCore::UI.error("Original error message:")
        FastlaneCore::UI.user_error!(e.message)
      end
    end

    def handle_tls_error!(e)
      # Apple has upgraded its iTunes Connect servers to require TLS 1.2, but
      # system Ruby 2.0 does not support it. We want to suggest that users upgrade
      # their Ruby version
      suggest_ruby_reinstall(e)
      display_user_error!(e, e.to_s)
    end

    def handle_ssl_error!(e)
      # SSL errors are very common when the Ruby or OpenSSL installation is somehow broken
      # We want to show a nice error message to the user here
      # We have over 20 GitHub issues just for this one error:
      #   https://github.com/fastlane/fastlane/search?q=errno%3D0+state%3DSSLv3+read+server&type=Issues
      suggest_ruby_reinstall(e)
      display_user_error!(e, e.to_s)
    end

    def suggest_ruby_reinstall(e)
      ui = FastlaneCore::UI
      ui.error "-----------------------------------------------------------------------"
      ui.error e.to_s
      ui.error ""
      ui.error "SSL errors can be caused by various components on your local machine."
      if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.1')
        ui.error "Apple has recently changed their servers to require TLS 1.2, which may"
        ui.error "not be available to your system installed Ruby (#{RUBY_VERSION})"
      end
      ui.error ""
      ui.error "The best solution is to use the self-contained fastlane version."
      ui.error "Which ships with a bundled OpenSSL,ruby and all gems - so you don't depend on system libraries"
      ui.error " - Use One-Click-Installer:"
      ui.error "    - download fastlane at https://download.fastlane.tools"
      ui.error "-----------------------------------------------------------"
      ui.error "    - extract the archive and double click the `install`"
      ui.error "-----------------------------------------------------------"
      ui.error " - Use Homebrew"
      ui.error "    - update brew with `brew update`"
      ui.error "    - install fastlane:"
      ui.error "-----------------------------------------------------------"
      ui.error "      - 🚀 `brew cask install fastlane` 🚀"
      ui.error "-----------------------------------------------------------"
      ui.error "for more details on ways to install fastlane please refer the documentation:"
      ui.error "-----------------------------------------------------------"
      ui.error "        🚀       https://docs.fastlane.tools          🚀   "
      ui.error "-----------------------------------------------------------"
      ui.error ""
      ui.error "You can also install a new version of Ruby"
      ui.error ""
      ui.error "- Make sure OpenSSL is installed with Homebrew: `brew update && brew upgrade openssl`"
      ui.error "- If you use system Ruby:"
      ui.error "  - Run `brew update && brew install ruby`"
      ui.error "- If you use rbenv with ruby-build:"
      ui.error "  - Run `brew update && brew upgrade ruby-build && rbenv install 2.3.1`"
      ui.error "  - Run `rbenv global 2.3.1` to make it the new global default Ruby version"
      ui.error "- If you use rvm:"
      ui.error "  - First run `rvm osx-ssl-certs update all`"
      ui.error "  - Then run `rvm reinstall ruby-2.3.1 --with-openssl-dir=/usr/local`"
      ui.error ""
      ui.error "If that doesn't fix your issue, please google for the following error message:"
      ui.error "  '#{e}'"
      ui.error "-----------------------------------------------------------------------"
    end

    def handle_unknown_error!(e)
      # Some spaceship exception classes implement #preferred_error_info in order to share error info
      # that we'd rather display instead of crashing with a stack trace. However, fastlane_core and
      # spaceship can not know about each other's classes! To make this information passing work, we
      # use a bit of Ruby duck-typing to check whether the unknown exception type implements the right
      # method. If so, we'll present any returned error info in the manner of a user_error!
      error_info = e.respond_to?(:preferred_error_info) ? e.preferred_error_info : nil
      should_show_github_issues = e.respond_to?(:show_github_issues) ? e.show_github_issues : true

      if error_info
        error_info = error_info.join("\n\t") if error_info.kind_of?(Array)

        show_github_issues(error_info) if should_show_github_issues

        display_user_error!(e, error_info)
      else
        # Pass the error instead of a message so that the inspector can do extra work to simplify the query
        show_github_issues(e) if should_show_github_issues

        # From https://stackoverflow.com/a/4789702/445598
        # We do this to make the actual error message red and therefore more visible
        reraise_formatted!(e, e.message)
      end
    end

    def display_user_error!(e, message)
      if FastlaneCore::Globals.verbose?
        # with stack trace
        reraise_formatted!(e, message)
      else
        # without stack trace
        abort "\n[!] #{message}".red
      end
    end

    def reraise_formatted!(e, message)
      raise e, "[!] #{message}".red, e.backtrace
    end

    def show_github_issues(message_or_error)
      return if FastlaneCore::Env.truthy?("FASTLANE_HIDE_GITHUB_ISSUES")
      return if FastlaneCore::Helper.test?

      require 'gh_inspector'
      require 'fastlane_core/ui/github_issue_inspector_reporter'

      inspector = GhInspector::Inspector.new("fastlane", "fastlane", verbose: FastlaneCore::Globals.verbose?)
      delegate = Fastlane::InspectorReporter.new
      if message_or_error.kind_of?(String)
        inspector.search_query(message_or_error, delegate)
      else
        inspector.search_exception(message_or_error, delegate)
      end
    rescue => ex
      FastlaneCore::UI.error("Error finding relevant GitHub issues: #{ex}") if FastlaneCore::Globals.verbose?
    end
  end
end
