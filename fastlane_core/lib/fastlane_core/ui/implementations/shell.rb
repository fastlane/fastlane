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
        if $verbose
          string = "#{severity} [#{datetime.strftime('%Y-%m-%d %H:%M:%S.%2N')}]: "
        elsif ENV["FASTLANE_HIDE_TIMESTAMP"]
          string = ""
        else
          string = "[#{datetime.strftime('%H:%M:%S')}]: "
        end

        string += "#{msg}\n"

        string
      end

      @log
    end

    #####################################################
    # @!group Messaging: show text to the user
    #####################################################

    def error(message)
      log.error(message.to_s.red)
    end

    def important(message)
      log.warn(message.to_s.yellow)
    end

    def success(message)
      log.info(message.to_s.green)
    end

    def message(message)
      log.info(message.to_s)
    end

    def deprecated(message)
      log.error(message.to_s.bold.blue)
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
      log.debug(message.to_s) if $verbose
    end

    def header(message)
      i = message.length + 8
      success("-" * i)
      success("--- " + message + " ---")
      success("-" * i)
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
      ask(message.to_s.yellow).to_s.strip
    end

    def confirm(message)
      verify_interactive!(message)
      agree("#{message} (y/n)".yellow, true)
    end

    def select(message, options)
      verify_interactive!(message)

      important(message)
      choose(*options)
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
