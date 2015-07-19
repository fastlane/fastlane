require "commander"
require "pilot/options"
require "fastlane_core"

HighLine.track_eof = false

module Pilot
  class CommandsGenerator
    include Commander::Methods

    FastlaneCore::CommanderGenerator.new.generate(Pilot::Options.available_options)

    def self.start
      FastlaneCore::UpdateChecker.start_looking_for_update("pilot")
      new.run
    ensure
      FastlaneCore::UpdateChecker.show_update_status("pilot", Pilot::VERSION)
    end

    def convert_options(options)
      o = options.__hash__.dup
      o.delete(:verbose)
      o
    end

    def run
      program :version, Pilot::VERSION
      program :description, Pilot::DESCRIPTION
      program :help, "Author", "Felix Krause <pilot@krausefx.com>"
      program :help, "Website", "https://fastlane.tools"
      program :help, "GitHub", "https://github.com/fastlane/pilot"
      program :help_formatter, :compact

      global_option("--verbose") { $verbose = true }

      always_trace!

      command :upload do |c|
        c.syntax = "pilot upload"
        c.description = "Uploads a new binary to Apple TestFlight"
        c.action do |_args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          Pilot::BuildManager.new.run(config)
        end
      end

      command :add do |c|
        c.syntax = "add"
        c.description = "Adds a new external tester to a specific app (if given). This will also add an existing tester to an app."
        c.action do |_args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          Pilot::TesterManager.new.add_tester(config)
        end
      end

      command :list do |c|
        c.syntax = "list"
        c.description = "Lists all registered testers, both internal and external"
        c.action do |_args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          Pilot::TesterManager.new.list_testers(config)
        end
      end

      command :export do |c|
        c.syntax = "export"
        c.description = "Exports all external testers to a CSV file"
        c.action do |_args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          Pilot::TesterExporter.new.export_testers(config)
        end
      end

      command :find do |c|
        c.syntax = "find"
        c.description = "Find a tester (internal or external) by their email address"
        c.action do |_args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          Pilot::TesterManager.new.find_tester(config)
        end
      end

      command :remove do |c|
        c.syntax = "remove"
        c.description = "Remove an external tester by their email address"
        c.action do |_args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          Pilot::TesterManager.new.remove_tester(config)
        end
      end

      default_command :help

      run!
    end
  end
end
