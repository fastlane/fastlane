module Chiizu
  class DependencyChecker
    def self.check_dependencies
      return if Helper.test?

      check_adb
    end

    def self.check_adb
      unless FastlaneCore::CommandExecutor.which('adb')
        UI.error 'The `adb` command could not be found on your PATH'
        UI.error "Please ensure that the Android tools are installed and the platform-tools directory is present and on your PATH"
        Ui.user_error! 'adb command not found'
      end
    end
  end
end
