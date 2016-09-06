module XcodeInstall
  class Command
    class Update < Command
      self.command = 'update'
      self.summary = 'Update cached list of available Xcodes.'

      def run
        installer = XcodeInstall::Installer.new
        installer.rm_list_cache
        installer.list
      end
    end
  end
end
