require 'fastlane_core/helper'

module FastlaneCore
  class ActionLaunchContext < AnalyticsContext
    attr_accessor :action_name
    attr_accessor :ide_version
    attr_accessor :fastfile
    alias fastfile? fastfile
    attr_accessor :fastfile_id
    attr_accessor :platform

    def fastlane_version
      return Fastlane::VERSION
    end

    def ruby_version
      patch_level = RUBY_PATCHLEVEL == 0 ? nil : "p#{RUBY_PATCHLEVEL}"
      return "#{RUBY_VERSION}#{patch_level}"
    end

    def operating_system
      return "macOS" if RUBY_PLATFORM.downcase.include?("darwin")
      return "Windows" if RUBY_PLATFORM.downcase.include?("mswin")
      return "Linux" if RUBY_PLATFORM.downcase.include?("linux")
      return "Unknown"
    end

    def install_method
      if Helper.rubygems?
        return 'gem'
      elsif Helper.bundler?
        return 'bundler'
      elsif Helper.mac_app?
        return 'mac_app'
      elsif Helper.contained_fastlane?
        return 'standalone'
      elsif Helper.homebrew?
        return 'homebrew'
      else
        return 'unknown'
      end
    end

    def ci?
      return Helper.is_ci?
    end

    def operating_system_version
      os = self.operating_system
      case os
      when "macOS"
        return `SW_VERS -productVersion`.strip
      else
        # Need to test in Windows and Linux... not sure this is enough
        return Gem::Platform.local.version
      end
    end
  end
end
