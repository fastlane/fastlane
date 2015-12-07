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

    def warn(message)
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

    def verbose(message)
      log.debug(message) if $verbose
    end

    #####################################################
    # @!group Errors: Different kinds of exceptions
    #####################################################

    def crash(exception)
      # todo: we should highlight the most important line
      raise exception
    end

    def user_error(error_message)
      abort(error_message.to_s.red.bold)
    end
  end
end
