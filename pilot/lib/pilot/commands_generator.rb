require "commander"

require 'fastlane_core/configuration/configuration'
require 'fastlane_core/ui/help_formatter'
require_relative 'module'
require_relative 'tester_importer'
require_relative 'tester_exporter'
require_relative 'tester_manager'
require_relative 'build_manager'
require_relative 'options'

HighLine.track_eof = false

module Pilot
  class CommandsGenerator
    include Commander::Methods

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
      config = create_config(options)
      args.push(config[:email]) if config[:email] && args.empty?
      args.push(UI.input("Email address of the tester: ")) if args.empty?
      failures = []
      args.each do |address|
        config[:email] = address
        begin
          mgr.public_send(action, config)
        rescue => ex
          # no need to show the email address in the message if only one specified
          message = (args.count > 1) ? "[#{address}]: #{ex}" : ex
          failures << message
          UI.error(message)
        end
      end
      UI.user_error!("Some operations failed: #{failures.join(', ')}") unless failures.empty?
    end

    def run
      program :name, 'pilot'
      program :version, Fastlane::VERSION
      program :description, Pilot::DESCRIPTION
      program :help, "Author", "Felix Krause <pilot@krausefx.com>"
      program :help, "Website", "https://fastlane.tools"
      program :help, "Documentation", "https://docs.fastlane.tools/actions/pilot/"
      program :help_formatter, FastlaneCore::HelpFormatter

      global_option("--verbose") { FastlaneCore::Globals.verbose = true }

      command :upload do |c|
        c.syntax = "fastlane pilot upload"
        c.description = "Uploads a new binary to Apple TestFlight"

        FastlaneCore::CommanderGenerator.new.generate(Pilot::Options.available_options, command: c)

        c.action do |args, options|
          config = create_config(options)
          Pilot::BuildManager.new.upload(config)
        end
      end

      command :distribute do |c|
        c.syntax = "fastlane pilot distribute"
        c.description = "Distribute a previously uploaded binary to Apple TestFlight"

        FastlaneCore::CommanderGenerator.new.generate(Pilot::Options.available_options, command: c)

        c.action do |args, options|
          config = create_config(options)
          Pilot::BuildManager.new.distribute(config)
        end
      end

      command :builds do |c|
        c.syntax = "fastlane pilot builds"
        c.description = "Lists all builds for given application"

        FastlaneCore::CommanderGenerator.new.generate(Pilot::Options.available_options, command: c)

        c.action do |args, options|
          config = create_config(options)
          Pilot::BuildManager.new.list(config)
        end
      end

      command :add do |c|
        c.syntax = "fastlane pilot add"
        c.description = "Adds new external tester(s) to a specific app (if given). This will also add an existing tester to an app."

        FastlaneCore::CommanderGenerator.new.generate(Pilot::Options.available_options, command: c)

        c.action do |args, options|
          handle_multiple('add_tester', args, options)
        end
      end

      command :list do |c|
        c.syntax = "fastlane pilot list"
        c.description = "Lists all registered testers, both internal and external"

        FastlaneCore::CommanderGenerator.new.generate(Pilot::Options.available_options, command: c)

        c.action do |args, options|
          config = create_config(options)
          UI.user_error!("You must include an `app_identifier` to list testers") unless config[:app_identifier]
          Pilot::TesterManager.new.list_testers(config)
        end
      end

      command :find do |c|
        c.syntax = "fastlane pilot find"
        c.description = "Find tester(s) (internal or external) by their email address"

        FastlaneCore::CommanderGenerator.new.generate(Pilot::Options.available_options, command: c)

        c.action do |args, options|
          handle_multiple('find_tester', args, options)
        end
      end

      command :remove do |c|
        c.syntax = "fastlane pilot remove"
        c.description = "Remove external tester(s) by their email address"

        FastlaneCore::CommanderGenerator.new.generate(Pilot::Options.available_options, command: c)

        c.action do |args, options|
          handle_multiple('remove_tester', args, options)
        end
      end

      command :export do |c|
        c.syntax = "fastlane pilot export"
        c.description = "Exports all external testers to a CSV file"

        FastlaneCore::CommanderGenerator.new.generate(Pilot::Options.available_options, command: c)

        c.action do |args, options|
          config = create_config(options)
          Pilot::TesterExporter.new.export_testers(config)
        end
      end

      command :import do |c|
        c.syntax = "fastlane pilot import"
        c.description = "Import external testers from a CSV file called testers.csv"

        FastlaneCore::CommanderGenerator.new.generate(Pilot::Options.available_options, command: c)

        c.action do |args, options|
          config = create_config(options)
          Pilot::TesterImporter.new.import_testers(config)
        end
      end

      default_command(:help)

      run!
    end

    def create_config(options)
      config = FastlaneCore::Configuration.create(Pilot::Options.available_options, convert_options(options))
      return config
    end
  end
end
