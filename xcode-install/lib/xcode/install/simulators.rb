require 'claide'

module XcodeInstall
  class Command
    class Simulators < Command
      self.command = 'simulators'
      self.summary = 'List or install iOS simulators.'

      def self.options
        [['--install=name', 'Install simulator beginning with name, e.g. \'iOS 8.4\', \'tvOS 9.0\'.']].concat(super)
      end

      def initialize(argv)
        @installed_xcodes = Installer.new.installed_versions
        @install = argv.option('install')
        super
      end

      def run
        @install ? install : list
      end
    end

    :private

    def install
      filtered_simulators = @installed_xcodes.map(&:available_simulators).flatten.uniq(&:name).select do |sim|
        sim.name.start_with?(@install)
      end
      case filtered_simulators.count
      when 0
        puts "[!] No simulator matching #{@install} was found. Please specify a version from the following available simulators:".ansi.red
        list
        exit 1
      when 1
        simulator = filtered_simulators.first
        raise Informative, "#{simulator.name} is already installed." if simulator.installed?
        puts "Installing #{simulator.name} for Xcode #{simulator.xcode.bundle_version}..."
        simulator.install
      else
        puts "[!] More than one simulator matching #{@install} was found. Please specify the full version.".ansi.red
        filtered_simulators.each do |candidate|
          puts "Xcode #{candidate.xcode.bundle_version} (#{candidate.xcode.path})".ansi.green
          puts "xcversion simulators --install=#{candidate.name}"
        end
        exit 1
      end
    end

    def list
      @installed_xcodes.each do |xcode|
        puts "Xcode #{xcode.version} (#{xcode.path})".ansi.green
        xcode.available_simulators.each do |simulator|
          puts simulator.to_s
        end
      end
    end
  end
end
