module XcodeInstall
  class Command
    class Select < Command
      self.command = 'select'
      self.summary = 'Select installed Xcode via `xcode-select`.'

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

        raise Informative, 'Please specify a version to select.' if @version.nil?
        raise Informative, "Version #{@version} not installed." unless @installer.installed?(@version)
      end

      def run
        xcode = @installer.installed_versions.detect { |v| v.version == @version }
        `sudo xcode-select --switch #{xcode.path}`
      end
    end
  end
end
