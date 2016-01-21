require 'logger'

module FastlaneCore
  # rubocop:disable Metrics/ModuleLength
  module Helper
    # Logging happens using this method
    def self.log
      $stdout.sync = true

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

    # Runs a given command using backticks (`)
    # and prints them out using the UI.command method
    def self.backticks(command, print: true)
      UI.command(command) if print
      result = `#{command}`
      UI.command_output(result) if print
      return result
    end

    # @return true if the currently running program is a unit test
    def self.test?
      defined?SpecHelper
    end

    # @return [boolean] true if building in a known CI environment
    def self.ci?
      # Check for Jenkins, Travis CI, ... environment variables
      ['JENKINS_URL', 'TRAVIS', 'CIRCLECI', 'CI', 'TEAMCITY_VERSION', 'GO_PIPELINE_NAME', 'bamboo_buildKey', 'GITLAB_CI'].each do |current|
        return true if ENV.key?(current)
      end
      return false
    end

    # Is the currently running computer a Mac?
    def self.mac?
      (/darwin/ =~ RUBY_PLATFORM) != nil
    end

    # Use Helper.test? and Helper.ci? instead (legacy calls)
    # rubocop:disable Style/PredicateName
    def self.is_test?
      self.test?
    end

    def self.is_ci?
      ci?
    end

    def self.is_mac?
      self.mac?
    end
    # rubocop:enable Style/PredicateName

    # Do we want to disable the colored output?
    def self.colors_disabled?
      ENV["FASTLANE_DISABLE_COLORS"]
    end

    # Does the user use the Mac stock terminal
    def self.mac_stock_terminal?
      !!ENV["TERM_PROGRAM_VERSION"]
    end

    # Does the user use iTerm?
    def self.iterm?
      !!ENV["ITERM_SESSION_ID"]
    end

    # All Xcode Related things
    #

    # @return the full path to the Xcode developer tools of the currently
    #  running system
    def self.xcode_path
      return "" if self.is_test? and !self.is_mac?
      `xcode-select -p`.delete("\n") + "/"
    end

    # @return The version of the currently used Xcode installation (e.g. "7.0")
    def self.xcode_version
      return @xcode_version if @xcode_version

      begin
        output = `DEVELOPER_DIR='' "#{xcode_path}/usr/bin/xcodebuild" -version`
        @xcode_version = output.split("\n").first.split(' ')[1]
      rescue => ex
        Helper.log.error ex
        Helper.log.error "Error detecting currently used Xcode installation".red
      end
      @xcode_version
    end

    # @return the full path to the iTMSTransporter executable
    def self.transporter_path
      return '' unless self.is_mac? # so tests work on Linx too

      [
        "../Applications/Application Loader.app/Contents/MacOS/itms/bin/iTMSTransporter",
        "../Applications/Application Loader.app/Contents/itms/bin/iTMSTransporter"
      ].each do |path|
        result = File.join(self.xcode_path, path)
        return result if File.exist?(result)
      end
      raise "Could not find transporter at #{self.xcode_path}. Please make sure you set the correct path to your Xcode installation.".red
    end

    def self.fastlane_enabled?
      # This is called from the root context on the first start
      @@enabled ||= File.directory? "./fastlane"
    end

    # Path to the installed gem to load resources (e.g. resign.sh)
    def self.gem_path(gem_name)
      if !Helper.is_test? and Gem::Specification.find_all_by_name(gem_name).any?
        return Gem::Specification.find_by_name(gem_name).gem_dir
      else
        return './'
      end
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
