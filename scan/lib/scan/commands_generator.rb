require "commander"
require "fastlane_core"

HighLine.track_eof = false

module Scan
  class CommandsGenerator
    include Commander::Methods

    FastlaneCore::CommanderGenerator.new.generate(Scan::Options.available_options)

    def self.start
      new.run
    end

    def convert_options(options)
      o = options.__hash__.dup
      o.delete(:verbose)
      o
    end

    def run
      program :name, 'scan'
      program :version, Fastlane::VERSION
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
          UI.user_error!("Scanfile already exists").yellow if File.exist?(path)
          template = File.read("#{Scan::ROOT}/lib/assets/ScanfileTemplate")
          File.write(path, template)
          UI.success("Successfully created '#{path}'. Open the file using a code editor.")
        end
      end

      default_command :tests

      run!
    end
  end
end
