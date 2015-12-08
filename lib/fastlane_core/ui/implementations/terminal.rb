module FastlaneCore
  # Terminal is the terminal output of things
  # For documentation for each of the methods open `interface.rb`
  class Terminal < Interface
    def log
      return @log if @log

      $stdout.sync = true

      if Helper.is_test?
        @log ||= Logger.new(nil) # don't show any logs when running tests
      else
        @log ||= Logger.new($stdout)
      end

      @log.formatter = proc do |severity, datetime, progname, msg|
        string = "#{severity} [#{datetime.strftime('%Y-%m-%d %H:%M:%S.%2N')}]: " if $verbose
        string = "[#{datetime.strftime('%H:%M:%S')}]: " unless $verbose

        string += "#{msg}\n"

        string
      end

      @log
    end

    #####################################################
    # @!group Messaging: show text to the user
    #####################################################

    def error(message)
      log.error(message.red)
    end

    def important(message)
      log.warn(message.yellow)
    end

    def success(message)
      log.info(message.green)
    end

    def message(message)
      log.info(message)
    end

    def command(message)
      log.info("$ #{message}".cyan.underline)
    end

    def command_output(message)
      actual = message.split("\r").last # as clearing the line will remove the `>` and the time stamp
      actual.split("\n").each do |msg|
        log.info("> #{msg}".magenta)
      end
    end

    def verbose(message)
      log.debug(message) if $verbose
    end

    def header(message)
      i = message.length + 8
      Helper.log.info(("-" * i).green)
      Helper.log.info(("--- " + message + " ---").green)
      Helper.log.info(("-" * i).green)
    end

    #####################################################
    # @!group Errors: Different kinds of exceptions
    #####################################################

    def crash!(exception)
      if exception.kind_of?(String)
        raise exception.red
      elsif exception.kind_of?(Exception)
        # From https://stackoverflow.com/a/4789702/445598
        # We do this to make the actual error message red and therefore more visible
        begin
          raise exception
        rescue => ex
          raise $!, ex.message.red, $!.backtrace
        end
      else
        raise exception # we're just raising whatever we have here #yolo
      end
    end

    def user_error!(error_message)
      if $verbose
        # On verbose we want to see the full stack trace
        raise error_message.to_s.red
      else
        abort(error_message.to_s.red)
      end
    end
  end
end
