require 'uri'

module XcodeInstall
  class Command
    class Install < Command
      self.command = 'install'
      self.summary = 'Install a specific version of Xcode.'

      self.arguments = [
        CLAide::Argument.new('VERSION', :true)
      ]

      def self.options
        [['--url', 'Custom Xcode DMG file path or HTTP URL.'],
         ['--force', 'Install even if the same version is already installed.'],
         ['--no-switch', 'Don’t switch to this version after installation'],
         ['--no-install', 'Only download DMG, but do not install it.'],
         ['--no-progress', 'Don’t show download progress.'],
         ['--no-clean', 'Don’t delete DMG after installation.']].concat(super)
      end

      def initialize(argv)
        @installer = Installer.new
        @version = argv.shift_argument
        @url = argv.option('url')
        @force = argv.flag?('force', false)
        @should_clean = argv.flag?('clean', true)
        @should_install = argv.flag?('install', true)
        @should_switch = argv.flag?('switch', true)
        @progress = argv.flag?('progress', true)
        super
      end

      def validate!
        super

        help! 'A VERSION argument is required.' unless @version
        raise Informative, "Version #{@version} already installed." if @installer.installed?(@version) && !@force
        raise Informative, "Version #{@version} doesn't exist." unless @url || @installer.exist?(@version)
        raise Informative, "Invalid URL: `#{@url}`" unless !@url || @url =~ /\A#{URI.regexp}\z/
      end

      def run
        @installer.install_version(@version, @should_switch, @should_clean, @should_install,
                                   @progress, @url)
      end
    end
  end
end
