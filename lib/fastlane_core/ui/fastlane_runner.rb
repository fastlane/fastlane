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

      begin
        run_active_command
      rescue InvalidCommandError => e
        abort "#{e}. Use --help for more information"
      rescue Interrupt => ex
        # We catch it so that the stack trace is hidden by default when using ctrl + c
        if $verbose
          raise ex
        else
          puts "\nCancelled... use --verbose to show the stack trace"
        end
      rescue \
        OptionParser::InvalidOption,
        OptionParser::InvalidArgument,
        OptionParser::MissingArgument => e
        abort e.to_s
      rescue FastlaneCore::Interface::FastlaneError => e # user_error!
        error_message = "\n[!] #{e}".red
        if $verbose # with stack trace
          raise e, "[!] #{e.message}".red, e.backtrace
        else
          abort error_message # without stack trace
        end
      rescue => e # high chance this is actually FastlaneCore::Interface::FastlaneCrash, but can be anything else
        FastlaneCore::CrashReporting.handle_crash(e)
        # From https://stackoverflow.com/a/4789702/445598
        # We do this to make the actual error message red and therefore more visible
        raise e, "[!] #{e.message}".red, e.backtrace
      end
    end
  end
end
