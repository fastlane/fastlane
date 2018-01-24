require_relative 'module'
require 'fastlane_core/command_executor'

module Screengrab
  class AndroidEnvironment
    attr_reader :android_home
    attr_reader :build_tools_version

    # android_home        - the String path to the install location of the Android SDK
    # build_tools_version - the String version of the Android build tools that should be used
    def initialize(android_home, build_tools_version)
      @android_home = android_home
      @build_tools_version = build_tools_version
    end

    def platform_tools_path
      @platform_tools_path ||= find_platform_tools(android_home)
    end

    def build_tools_path
      @build_tools_path ||= find_build_tools(android_home, build_tools_version)
    end

    def adb_path
      @adb_path ||= find_adb(platform_tools_path)
    end

    def aapt_path
      @aapt_path ||= find_aapt(build_tools_path)
    end

    private

    def find_platform_tools(android_home)
      return nil unless android_home

      platform_tools_path = File.join(android_home, 'platform-tools')
      File.directory?(platform_tools_path) ? platform_tools_path : nil
    end

    def find_build_tools(android_home, build_tools_version)
      return nil unless android_home

      build_tools_dir = File.join(android_home, 'build-tools')

      return nil unless build_tools_dir && File.directory?(build_tools_dir)

      return File.join(build_tools_dir, build_tools_version) if build_tools_version

      version = select_build_tools_version(build_tools_dir)

      return version ? File.join(build_tools_dir, version) : nil
    end

    def select_build_tools_version(build_tools_dir)
      # Collect the sub-directories of the build_tools_dir, rejecting any that start with '.' to remove . and ..
      dir_names = Dir.entries(build_tools_dir).select { |e| !e.start_with?('.') && File.directory?(File.join(build_tools_dir, e)) }

      # Collect a sorted array of Version objects from the directory names, handling the possibility that some
      # entries may not be valid version names
      versions = dir_names.map do |d|
        begin
          Gem::Version.new(d)
        rescue
          nil
        end
      end.reject(&:nil?).sort

      # We'll take the last entry (highest version number) as the directory name we want
      versions.last.to_s
    end

    def find_adb(platform_tools_path)
      return FastlaneCore::CommandExecutor.which('adb') unless platform_tools_path

      adb_path = File.join(platform_tools_path, 'adb')
      return executable_command?(adb_path) ? adb_path : nil
    end

    def find_aapt(build_tools_path)
      return FastlaneCore::CommandExecutor.which('aapt') unless build_tools_path

      aapt_path = File.join(build_tools_path, 'aapt')
      return executable_command?(aapt_path) ? aapt_path : nil
    end

    def executable_command?(cmd_path)
      Helper.executable?(cmd_path)
    end
  end
end
