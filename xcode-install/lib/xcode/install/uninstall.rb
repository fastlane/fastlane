module XcodeInstall
  class Command
    class Uninstall < Command
      self.command = 'uninstall'
      self.summary = 'Uninstall a specific version of Xcode.'

      self.arguments = [
        CLAide::Argument.new('VERSION', :true)
      ]

      def initialize(argv)
        @installer = Installer.new
        @version = argv.shift_argument
        super
      end

      def validate!
        super
        help! 'A VERSION argument is required.' unless @version

        raise Informative, "Version #{@version} is not installed." unless @installer.installed?(@version)
      end

      def run
        installed_path = @installer.installed_versions.find { |x| x.version == @version }
        return if installed_path.nil? || installed_path.path.nil?

        `sudo rm -rf #{installed_path.path}`

        return unless @installer.symlinks_to == installed_path.path
        newest_version = @installer.installed_versions.last
        @installer.symlink(newest_version)
      end
    end
  end
end
