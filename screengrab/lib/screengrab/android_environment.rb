require_relative 'module'
require 'fastlane_core/command_executor'

module Screengrab
  class AndroidEnvironment
    attr_reader :android_home

    # android_home        - the String path to the install location of the Android SDK
    # build_tools_version - the String version of the Android build tools that should be used, ignored
    def initialize(android_home, build_tools_version = nil)
      @android_home = android_home
    end

    def platform_tools_path
      @platform_tools_path ||= find_platform_tools(android_home)
    end

    def adb_path
      @adb_path ||= find_adb(platform_tools_path)
    end

    private

    def find_platform_tools(android_home)
      return nil unless android_home

      platform_tools_path = Helper.localize_file_path(File.join(android_home, 'platform-tools'))
      File.directory?(platform_tools_path) ? platform_tools_path : nil
    end

    def find_adb(platform_tools_path)
      return FastlaneCore::CommandExecutor.which('adb') unless platform_tools_path

      adb_path = Helper.get_executable_path(File.join(platform_tools_path, 'adb'))
      adb_path = Helper.localize_file_path(adb_path)
      return executable_command?(adb_path) ? adb_path : nil
    end

    def executable_command?(cmd_path)
      Helper.executable?(cmd_path)
    end
  end
end
