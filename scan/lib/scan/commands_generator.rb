require "commander"
require "fastlane_core"

HighLine.track_eof = false

module Scan
  class CommandsGenerator
    include Commander::Methods

    FastlaneCore::CommanderGenerator.new.generate(Scan::Options.available_options)

    def self.start
      FastlaneCore::UpdateChecker.start_looking_for_update("scan")
      new.run
    ensure
      FastlaneCore::UpdateChecker.show_update_status("scan", Scan::VERSION)
    end

    def convert_options(options)
      o = options.__hash__.dup
      o.delete(:verbose)
      o
    end

    def run
      program :version, Scan::VERSION
      program :description, Scan::DESCRIPTION
      program :help, "Author", "Felix Krause <scan@krausefx.com>"
      program :help, "Website", "https://fastlane.tools"
      program :help, "GitHub", "https://github.com/fastlane/fastlane/tree/master/scan"
      program :help_formatter, :compact

      global_option("--verbose") { $verbose = true }

      command :tests do |c|
        c.syntax = "scan"
        c.description = Scan::DESCRIPTION
        c.action do |_args, options|
          config = FastlaneCore::Configuration.create(Scan::Options.available_options,
                                                      convert_options(options))
          Scan::Manager.new.work(config)
        end
      end

      command :init do |c|
        c.syntax = "scan init"
        c.description = "Creates a new Scanfile for you"
        c.action do |_args, options|
          containing = (Helper.fastlane_enabled? ? 'fastlane' : '.')
          path = File.join(containing, Scan.scanfile_name)
          raise "Scanfile already exists".yellow if File.exist?(path)
          template = File.read("#{Helper.gem_path('scan')}/lib/assets/ScanfileTemplate")
          File.write(path, template)
          Helper.log.info "Successfully created '#{path}'. Open the file using a code editor.".green
        end
      end

      default_command :tests

      run!
    end
  end
end
