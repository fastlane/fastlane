require 'logger'
require 'colored'

module FastlaneCore
  # rubocop:disable Metrics/ModuleLength
  module Helper
    # This method is deprecated, use the `UI` class
    # https://github.com/fastlane/fastlane/blob/master/fastlane/docs/UI.md
    def self.log
      UI.deprecated "Helper.log is deprecated. Use `UI` class instead"
      UI.current.log
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
      defined? SpecHelper
    end

    # removes ANSI colors from string
    def self.strip_ansi_colors(str)
      str.gsub(/\e\[([;\d]+)?m/, '')
    end

    # @return [boolean] true if executing with bundler (like 'bundle exec fastlane [action]')
    def self.bundler?
      # Bundler environment variable
      ['BUNDLE_BIN_PATH', 'BUNDLE_GEMFILE'].each do |current|
        return true if ENV.key?(current)
      end
      return false
    end

    # Do we run from a bundled fastlane, which contains Ruby and OpenSSL?
    # Usually this means the fastlane directory is ~/.fastlane/bin/
    # We set this value via the environment variable `FASTLANE_SELF_CONTAINED`
    def self.contained_fastlane?
      ENV["FASTLANE_SELF_CONTAINED"].to_s == "true" && !self.homebrew?
    end

    # returns true if fastlane was installed from the Fabric Mac app
    def self.mac_app?
      ENV["FASTLANE_SELF_CONTAINED"].to_s == "false"
    end

    # returns true if fastlane was installed via Homebrew
    def self.homebrew?
      ENV["FASTLANE_INSTALLED_VIA_HOMEBREW"].to_s == "true"
    end

    # returns true if fastlane was installed via RubyGems
    def self.rubygems?
      !self.bundler? && !self.contained_fastlane? && !self.homebrew? && !self.mac_app?
    end

    # @return [boolean] true if building in a known CI environment
    def self.ci?
      # Check for Jenkins, Travis CI, ... environment variables
      ['JENKINS_HOME', 'JENKINS_URL', 'TRAVIS', 'CIRCLECI', 'CI', 'TEAMCITY_VERSION', 'GO_PIPELINE_NAME', 'bamboo_buildKey', 'GITLAB_CI', 'XCS'].each do |current|
        return true if ENV.key?(current)
      end
      return false
    end

    def self.windows?
      # taken from: http://stackoverflow.com/a/171011/1945875
      (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end

    def self.linux?
      (/linux/ =~ RUBY_PLATFORM) != nil
    end

    # Is the currently running computer a Mac?
    def self.mac?
      (/darwin/ =~ RUBY_PLATFORM) != nil
    end

    # Use Helper.test? and Helper.ci? instead (legacy calls)
    def self.is_test?
      self.test?
    end

    def self.is_ci?
      ci?
    end

    def self.is_mac?
      self.mac?
    end

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

    # Logs base directory
    def self.buildlog_path
      return ENV["FL_BUILDLOG_PATH"] || "~/Library/Logs"
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
        UI.error(ex)
        UI.error("Error detecting currently used Xcode installation")
      end
      @xcode_version
    end

    def self.transporter_java_executable_path
      return File.join(self.transporter_java_path, 'bin', 'java')
    end

    def self.transporter_java_ext_dir
      return File.join(self.transporter_java_path, 'lib', 'ext')
    end

    def self.transporter_java_jar_path
      return File.join(self.itms_path, 'lib', 'itmstransporter-launcher.jar')
    end

    def self.transporter_user_dir
      return File.join(self.itms_path, 'bin')
    end

    def self.transporter_java_path
      return File.join(self.itms_path, 'java')
    end

    # @return the full path to the iTMSTransporter executable
    def self.transporter_path
      return File.join(self.itms_path, 'bin', 'iTMSTransporter')
    end

    def self.keychain_path(name)
      # Existing code expects that a keychain name will be expanded into a default path to Libary/Keychains
      # in the user's home directory. However, this will not allow the user to pass an absolute path
      # for the keychain value
      #
      # So, if the passed value can't be resolved as a file in Library/Keychains, just use it as-is
      # as the keychain path.
      #
      # We need to expand each path because File.exist? won't handle directories including ~ properly
      #
      # We also try to append `-db` at the end of the file path, as with Sierra the default Keychain name
      # has changed for some users: https://github.com/fastlane/fastlane/issues/5649
      #

      # Remove the ".keychain" at the end of the name
      name.sub!(/\.keychain$/, "")

      possible_locations = [
        File.join(Dir.home, 'Library', 'Keychains', name),
        name
      ].map { |path| File.expand_path(path) }

      # Transforms ["thing"] to ["thing", "thing-db", "thing.keychain", "thing.keychain-db"]
      keychain_paths = []
      possible_locations.each do |location|
        keychain_paths << location
        keychain_paths << "#{location}-db"
        keychain_paths << "#{location}.keychain"
        keychain_paths << "#{location}.keychain-db"
      end

      keychain_path = keychain_paths.find { |path| File.exist?(path) }
      UI.user_error!("Could not locate the provided keychain. Tried:\n\t#{keychain_paths.join("\n\t")}") unless keychain_path
      keychain_path
    end

    # @return the full path to the iTMSTransporter executable
    def self.itms_path
      return ENV["FASTLANE_ITUNES_TRANSPORTER_PATH"] if ENV["FASTLANE_ITUNES_TRANSPORTER_PATH"]
      return '' unless self.is_mac? # so tests work on Linx too

      [
        "../Applications/Application Loader.app/Contents/MacOS/itms",
        "../Applications/Application Loader.app/Contents/itms"
      ].each do |path|
        result = File.expand_path(File.join(self.xcode_path, path))
        return result if File.exist?(result)
      end
      UI.user_error!("Could not find transporter at #{self.xcode_path}. Please make sure you set the correct path to your Xcode installation.")
    end

    def self.fastlane_enabled?
      # This is called from the root context on the first start
      @enabled ||= (File.directory?("./fastlane") || File.directory?("./.fastlane"))
    end

    # <b>DEPRECATED:</b> Use the `ROOT` constant from the appropriate tool module instead
    # e.g. File.join(Sigh::ROOT, 'lib', 'assets', 'resign.sh')
    #
    # Path to the installed gem to load resources (e.g. resign.sh)
    def self.gem_path(gem_name)
      UI.deprecated('`Helper.gem_path` is deprecated. Use the `ROOT` constant from the appropriate tool module instead.')

      if !Helper.is_test? and Gem::Specification.find_all_by_name(gem_name).any?
        return Gem::Specification.find_by_name(gem_name).gem_dir
      else
        return './'
      end
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
