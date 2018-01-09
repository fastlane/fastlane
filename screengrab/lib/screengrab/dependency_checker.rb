require_relative 'module'

module Screengrab
  class DependencyChecker
    def self.check(android_env)
      return if Helper.test?

      check_adb(android_env)
      check_aapt(android_env)
    end

    def self.check_adb(android_env)
      android_home = android_env.android_home
      adb_path = android_env.adb_path

      warn_if_command_path_not_relative_to_android_home('adb', android_home, adb_path)
      # adb is required to function, so we'll quit noisily if we couldn't find it
      raise_missing_adb(android_home) unless adb_path
    end

    def self.raise_missing_adb(android_home)
      if android_home
        UI.error("The `adb` command could not be found relative to your provided ANDROID_HOME at #{android_home}")
        UI.error("Please ensure that the Android SDK is installed and the platform-tools directory is present")
      else
        UI.error('The `adb` command could not be found on your PATH')
        UI.error('Please ensure that the Android SDK is installed and the platform-tools directory is present and on your PATH')
      end

      UI.user_error!('adb command not found')
    end

    def self.check_aapt(android_env)
      android_home = android_env.android_home
      aapt_path = android_env.aapt_path

      warn_if_command_path_not_relative_to_android_home('aapt', android_home, aapt_path)
      # aapt is not required in order to function, so we'll only warn if we can't find it.
      warn_missing_aapt(android_home) unless aapt_path
    end

    def self.warn_missing_aapt(android_home)
      if android_home
        UI.important("The `aapt` command could not be found relative to your provided ANDROID_HOME at #{android_home}")
        UI.important("Please ensure that the Android SDK is installed and you have the build tools downloaded")
      else
        UI.important("The `aapt` command could not be found on your PATH")
        UI.important("Please ensure that the Android SDK is installed and you have the build tools downloaded and present on your PATH")
      end
    end

    def self.warn_if_command_path_not_relative_to_android_home(cmd_name, android_home, cmd_path)
      if android_home && cmd_path && !cmd_path.start_with?(android_home)
        UI.important("Using `#{cmd_name}` found at #{cmd_path} which is not within the specified ANDROID_HOME at #{android_home}")
      end
    end
  end
end
