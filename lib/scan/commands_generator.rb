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
      program :help, "GitHub", "https://github.com/fastlane/scan"
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

      default_command :tests

      run!
    end
  end
end
