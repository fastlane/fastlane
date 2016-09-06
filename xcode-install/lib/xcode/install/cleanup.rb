module XcodeInstall
  class Command
    class Cleanup < Command
      self.command = 'cleanup'
      self.summary = 'Cleanup cached downloads.'

      def run
        installer = XcodeInstall::Installer.new
        return if installer.cache_dir.nil? || installer.cache_dir.to_s.length < 5
        FileUtils.rm_f(Dir.glob("#{installer.cache_dir}/*"))
      end
    end
  end
end
