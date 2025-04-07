require_relative '../../helper'
require_relative '../../globals'
require_relative '../../env'

require_relative '../interface'

module FastlaneCore
  # Shell is the terminal output of things
  # For documentation for each of the methods open `interface.rb`
  class Shell < Interface
    require 'tty-screen'

    def log
      return @log if @log

      $stdout.sync = true

      if Helper.test? && !ENV.key?('DEBUG')
        $stdout.puts("Logging disabled while running tests. Force them by setting the DEBUG environment variable")
        @log ||= Logger.new(nil) # don't show any logs when running tests
      else
        @log ||= Logger.new($stdout)
      end

      @log.formatter = proc do |severity, datetime, progname, msg|
        "#{format_string(datetime, severity)}#{msg}\n"
      end

      @log
    end

    def format_string(datetime = Time.now, severity = "")
      timezone_string = !FastlaneCore::Env.truthy?('FASTLANE_SHOW_TIMEZONE') ? '' : ' %z'
      if FastlaneCore::Globals.verbose?
        return "#{severity} [#{datetime.strftime('%Y-%m-%d %H:%M:%S.%2N' + timezone_string)}]: "
      elsif FastlaneCore::Env.truthy?("FASTLANE_HIDE_TIMESTAMP")
        return ""
      else
        return "[#{datetime.strftime('%H:%M:%S' + timezone_string)}]: "
      end
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
      log.error(message.to_s.deprecated)
    end

    def command(message)
      log.info("$ #{message}".cyan)
    end

    def command_output(message)
      actual = (encode_as_utf_8_if_possible(message).split("\r").last || "") # as clearing the line will remove the `>` and the time stamp
      actual.split("\n").each do |msg|
        if FastlaneCore::Env.truthy?("FASTLANE_DISABLE_OUTPUT_FORMAT")
          log.info(msg)
        else
          prefix = msg.include?("▸") ? "" : "▸ "
          log.info(prefix + "" + msg.magenta)
        end
      end
    end

    def verbose(message)
      log.debug(message.to_s) if FastlaneCore::Globals.verbose?
    end

    def header(message)
      format = format_string
      # clamp to zero to prevent negative argument error below
      available_width = [0, TTY::Screen.width - format.length].max
      if message.length + 8 < available_width
        message = "--- #{message} ---"
        i = message.length
      else
        i = available_width
      end
      success("-" * i)
      success(message)
      success("-" * i)
    end

    def content_error(content, error_line)
      error_line = error_line.to_i
      return unless error_line > 0

      contents = content.split(/\r?\n/).map(&:chomp)

      start_line = error_line - 2 < 1 ? 1 : error_line - 2
      end_line = error_line + 2 < contents.length ? error_line + 2 : contents.length

      error('```')
      Range.new(start_line, end_line).each do |line|
        str = line == error_line ? " => " : "    "
        str << line.to_s.rjust(Math.log10(end_line) + 1)
        str << ":\t#{contents[line - 1]}"
        error(str)
      end
      error('```')
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
      ask("#{format_string}#{message.to_s.yellow}").to_s.strip
    end

    def confirm(message)
      verify_interactive!(message)
      agree("#{format_string}#{message.to_s.yellow} (y/n)", true)
    end

    def select(message, options)
      verify_interactive!(message)

      important(message)
      choose(*options)
    end

    def password(message)
      verify_interactive!(message)

      ask("#{format_string}#{message.to_s.yellow}") do |q|
        q.whitespace = :chomp
        q.echo = "*"
      end
    end

    private

    def encode_as_utf_8_if_possible(message)
      return message if message.valid_encoding?

      # genstrings outputs UTF-16, so we should try to use this encoding if it turns out to be valid
      test_message = message.dup
      return message.encode(Encoding::UTF_8, Encoding::UTF_16) if test_message.force_encoding(Encoding::UTF_16).valid_encoding?

      # replace any invalid with empty string
      message.encode(Encoding::UTF_8, invalid: :replace)
    end

    def verify_interactive!(message)
      return if interactive?
      important(message)
      crash!("Could not retrieve response as fastlane runs in non-interactive mode")
    end
  end
end
