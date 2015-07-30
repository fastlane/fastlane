require 'logger'

module FastlaneCore
  module Helper

    # Logging happens using this method
    def self.log
      if is_test?
        @@log ||= Logger.new(nil) # don't show any logs when running tests
      else
        @@log ||= Logger.new($stdout)
      end

      @@log.formatter = proc do |severity, datetime, progname, msg|
        string = "#{severity} [#{datetime.strftime('%Y-%m-%d %H:%M:%S.%2N')}]: " if $verbose
        string = "[#{datetime.strftime('%H:%M:%S')}]: " unless $verbose
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

    # This method can be used to add nice lines around the actual log
    # Use this to log more important things
    # The logs will be green automatically
    def self.log_alert(text)
      i = text.length + 8
      Helper.log.info(("-" * i).green)
      Helper.log.info("--- ".green + text.green + " ---".green)
      Helper.log.info(("-" * i).green)
    end

    # @return true if the currently running program is a unit test
    def self.test?
      defined?SpecHelper
    end

    # Use Helper.test? instead
    def self.is_test?
      self.test?
    end

    # @return [boolean] true if building in a known CI environment
    def self.is_ci?
      # Check for Jenkins, Travis CI, ... environment variables
      ['JENKINS_URL', 'TRAVIS', 'CIRCLECI', 'CI'].each do |current|
        return true if ENV.has_key?(current)
      end
      return false
    end

    # @return the full path to the Xcode developer tools of the currently
    #  running system
    def self.xcode_path
      return "" if self.is_test? and not self.is_mac?
      `xcode-select -p`.gsub("\n", '') + "/"
    end

    # Is the currently running computer a Mac?
    def self.is_mac?
      (/darwin/ =~ RUBY_PLATFORM) != nil
    end

    # @return the full path to the iTMSTransporter executable
    def self.transporter_path
      return '' unless self.is_mac? # so tests work on Linx too

      [
        "../Applications/Application Loader.app/Contents/MacOS/itms/bin/iTMSTransporter",
        "../Applications/Application Loader.app/Contents/itms/bin/iTMSTransporter"
      ].each do |path|
        result = File.join(self.xcode_path, path)
        return result if File.exists?(result)
      end
      raise "Could not find transporter at #{self.xcode_path}. Please make sure you set the correct path to your Xcode installation.".red
    end

    def self.fastlane_enabled?
      # This is called from the root context on the first start
      @@enabled ||= File.directory?"./fastlane"
    end

    # Path to the installed gem to load resources (e.g. resign.sh)
    def self.gem_path(gem_name)
      if not Helper.is_test? and Gem::Specification::find_all_by_name(gem_name).any?
        return Gem::Specification.find_by_name(gem_name).gem_dir
      else
        return './'
      end
    end
  end
end
