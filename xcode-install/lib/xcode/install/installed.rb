module XcodeInstall
  class Command
    class Installed < Command
      self.command = 'installed'
      self.summary = 'List installed Xcodes.'

      def self.options
        [['--uuid', 'Show DVTPlugInCompatibilityUUIDs in the list.']].concat(super)
      end

      def initialize(argv)
        @uuid = argv.flag?('uuid', false)
        super
      end

      def run
        installer = XcodeInstall::Installer.new
        installer.installed_versions.each do |xcode|
          puts "#{xcode.version}\t(#{xcode.path})\t#{@uuid ? xcode.uuid : ''}"
        end
      end
    end
  end
end
