require 'logger'

module Snapshot
  class Helper


    # Logging happens using this method
    def self.log
      if is_test?
        @@log ||= Logger.new(STDOUT) # don't show any logs when running tests
      else
        @@log ||= Logger.new(STDOUT)
      end

      @@log.formatter = proc do |severity, datetime, progname, msg|
        string = "#{severity} [#{datetime.strftime('%Y-%m-%d %H:%M:%S.%2N')}]: "
        second = "#{msg}\n"

        if severity == "DEBUG"
          string = string.magenta
        elsif severity == "INFO"
          string = string.white
        elsif severity == "WARN"
          string = string.yellow
        elsif severity == "ERROR"
          string = string.red
        elsif severity == "FATAL"
          string = string.red.bold
        end


        [string, second].join("")
      end

      @@log
    end

    # @return true if the currently running program is a unit test
    def self.is_test?
      defined?SpecHelper
    end

    # @return the full path to the Xcode developer tools of the currently
    #  running system
    def self.xcode_path
      return "" if self.is_test? and not OS.mac?
      `xcode-select -p`.gsub("\n", '') + "/"
    end

    def self.fastlane_enabled?
      # This is called from the root context on the first start
      @@enabled ||= File.directory?"./fastlane"
    end
  end
end