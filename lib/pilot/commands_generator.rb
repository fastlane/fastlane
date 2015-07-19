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

      command :fly do |c|
        c.syntax = "pilot"
        c.description = "Uploads a new binary to Apple TestFlight"
        c.action do |_args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          Pilot::BuildManager.new.run(config)
        end
      end

      command :add_tester do |c|
        c.syntax = "add_external_tester"
        c.description = "Adds a new external tester"
        c.action do |_args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          Pilot::TesterManager.new.add_tester(config)
        end
      end

      command :find_tester do |c|
        c.syntax = "find_tester"
        c.description = "Find a tester (internal or external) by their email address"
        c.action do |_args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          Pilot::TesterManager.new.find_tester_by_email(config)
        end
      end

      command :add_tester_to_app do |c|
        c.syntax = "add_tester_to_app"
        c.description = "Adds an existing tester to an app"
        c.action do |_args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          Pilot::TesterManager.new.add_tester_to_app(config)
        end
      end

      command :remove_tester do |c|
        c.syntax = "remove_tester"
        c.description = "Remove an external tester by their email address"
        c.action do |_args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          Pilot::TesterManager.new.remove_tester(config, true)
        end
      end

      command :reinvite_tester do |c|
        c.syntax = "reinvite_tester"
        c.description = "Reinvite an external tester"
        c.action do |_args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          Pilot::TesterManager.new.reinvite_tester(config)
        end
      end

      default_command :help

      run!
    end
  end
end
