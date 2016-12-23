require "commander"
require "pilot/options"
require "fastlane_core"

HighLine.track_eof = false

module Pilot
  class CommandsGenerator
    include Commander::Methods

    FastlaneCore::CommanderGenerator.new.generate(Pilot::Options.available_options)

    def self.start
      new.run
    end

    def convert_options(options)
      o = options.__hash__.dup
      o.delete(:verbose)
      o
    end

    def handle_multiple(action, args, options)
      mgr = Pilot::TesterManager.new
      config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
      args.push(config[:email]) if config[:email] && args.empty?
      args.push(UI.input("Email address of the tester: ")) if args.empty?
      failures = []
      args.each do |address|
        config[:email] = address
        begin
          mgr.public_send(action, config)
        rescue => ex
          failures.push(address)
          UI.message("[#{address}]: #{ex}")
        end
      end
      UI.user_error!("Some operations failed: #{failures}") unless failures.empty?
    end

    def run
      program :name, 'pilot'
      program :version, Fastlane::VERSION
      program :description, Pilot::DESCRIPTION
      program :help, "Author", "Felix Krause <pilot@krausefx.com>"
      program :help, "Website", "https://fastlane.tools"
      program :help, "GitHub", "https://github.com/fastlane/fastlane/tree/master/pilot"
      program :help_formatter, :compact

      global_option("--verbose") { $verbose = true }

      command :upload do |c|
        c.syntax = "pilot upload"
        c.description = "Uploads a new binary to Apple TestFlight"
        c.action do |args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          Pilot::BuildManager.new.upload(config)
        end
      end

      command :distribute do |c|
        c.syntax = "pilot distribute"
        c.description = "Distribute a previously uploaded binary to Apple TestFlight"
        c.action do |args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          config[:distribute_external] = true
          Pilot::BuildManager.new.distribute(config)
        end
      end

      command :builds do |c|
        c.syntax = "pilot builds"
        c.description = "Lists all builds for given application"
        c.action do |args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          Pilot::BuildManager.new.list(config)
        end
      end

      command :add do |c|
        c.syntax = "pilot add"
        c.description = "Adds new external tester(s) to a specific app (if given). This will also add an existing tester to an app."
        c.action do |args, options|
          handle_multiple('add_tester', args, options)
        end
      end

      command :list do |c|
        c.syntax = "pilot list"
        c.description = "Lists all registered testers, both internal and external"
        c.action do |args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          Pilot::TesterManager.new.list_testers(config)
        end
      end

      command :find do |c|
        c.syntax = "pilot find"
        c.description = "Find tester(s) (internal or external) by their email address"
        c.action do |args, options|
          handle_multiple('find_tester', args, options)
        end
      end

      command :remove do |c|
        c.syntax = "pilot remove"
        c.description = "Remove external tester(s) by their email address"
        c.action do |args, options|
          handle_multiple('remove_tester', args, options)
        end
      end

      command :export do |c|
        c.syntax = "pilot export"
        c.description = "Exports all external testers to a CSV file"
        c.action do |args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          Pilot::TesterExporter.new.export_testers(config)
        end
      end

      command :import do |c|
        c.syntax = "pilot import"
        c.description = "Create external testers from a CSV file"
        c.action do |args, options|
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
          Pilot::TesterImporter.new.import_testers(config)
        end
      end

      default_command :help

      run!
    end
  end
end
