module FastlaneCore
  # Shell is the terminal output of things
  # For documentation for each of the methods open `interface.rb`
  class Shell < Interface
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
      actual = (message.split("\r").last || "") # as clearing the line will remove the `>` and the time stamp
      actual.split("\n").each do |msg|
        prefix = msg.include?("▸") ? "" : "▸ "
        log.info(prefix + "" + msg.magenta)
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
    # @!group Errors: Inputs
    #####################################################

    def interactive?
      interactive = true
      interactive = false if $stdout.isatty == false
      interactive = false if Helper.ci?
      return interactive
    end

    def input(message)
      verify_interactive!(message)
      ask(message)
    end

    def confirm(message)
      verify_interactive!(message)
      agree("#{message} (y/n)", true)
    end

    def select(message, options)
      verify_interactive!(message)

      important(message)
      choose(*(options))
    end

    def password(message)
      verify_interactive!(message)

      ask(message.yellow) { |q| q.echo = "*" }
    end

    private

    def verify_interactive!(message)
      return if interactive?
      important(message)
      crash!("Could not retrieve response as fastlane runs in non-interactive mode")
    end
  end
end
