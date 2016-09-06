module XcodeInstall
  class Command
    class List < Command
      self.command = 'list'
      self.summary = 'List Xcodes available for download.'

      def self.options
        [['--all', 'Show all available versions.']].concat(super)
      end

      def initialize(argv)
        @all = argv.flag?('all', false)
        super
      end

      def run
        installer = XcodeInstall::Installer.new

        if @all
          puts installer.list
        else
          puts installer.list_current
        end
      end
    end
  end
end
