require "commander"
require "fastlane_core"
require 'fastlane_core/ui/help_formatter'
require "supply"

HighLine.track_eof = false

module Supply
  class CommandsGenerator
    include Commander::Methods

    def self.start
      new.run
    end

    def run
      program :name, 'supply'
      program :version, Fastlane::VERSION
      program :description, Supply::DESCRIPTION
      program :help, 'Author', 'Felix Krause <supply@krausefx.com>'
      program :help, 'Website', 'https://fastlane.tools'
      program :help, 'Documentation', 'https://docs.fastlane.tools/actions/supply/'
      program :help_formatter, FastlaneCore::HelpFormatter

      always_trace!

      global_option('--verbose') { FastlaneCore::Globals.verbose = true }
      global_option('--env STRING[,STRING2]', String, 'Add environment(s) to use with `dotenv`')

      command :run do |c|
        c.syntax = 'fastlane supply'
        c.description = 'Run a deploy process'

        FastlaneCore::CommanderGenerator.new.generate(Supply::Options.available_options, command: c)

        c.action do |args, options|
          Supply.config = FastlaneCore::Configuration.create(Supply::Options.available_options, options.__hash__)
          load_supplyfile

          Supply::Uploader.new.perform_upload
        end
      end

      command :init do |c|
        c.syntax = 'fastlane supply init'
        c.description = 'Sets up supply for you'

        FastlaneCore::CommanderGenerator.new.generate(Supply::Options.available_options, command: c)

        c.action do |args, options|
          require 'supply/setup'
          Supply.config = FastlaneCore::Configuration.create(Supply::Options.available_options, options.__hash__)
          load_supplyfile

          Supply::Setup.new.perform_download
        end
      end

      command :api do |c|
        c.syntax = 'fastlane supply api <METHOD> <PATH> [options]'
        c.description = "Send one Google Play Developer API request and print Google's JSON response"
        c.option('--body JSON', String, 'Request body: JSON text, or @path to a JSON file')
        c.option('--paginate', 'Follow the next page token and print all pages as one response (GET only)')
        c.option('--json_key PATH', String, 'Service account JSON file. Without it, SUPPLY_JSON_KEY(_DATA), else Application Default Credentials')
        c.option('--json_key_data JSON', String, 'Service account JSON data')
        c.option('--yes', 'Confirm a DELETE request')
        c.example('List reviews', 'fastlane supply api GET /androidpublisher/v3/applications/com.example/reviews --paginate --json_key key.json')
        c.example('Open an edit', 'fastlane supply api POST /androidpublisher/v3/applications/com.example/edits --json_key key.json')

        c.action do |args, options|
          require 'supply/api_runner'
          UI.user_error!("Usage: #{c.syntax}") unless args.size == 2
          output = Supply::ApiRunner.new(
            method: args[0],
            path: args[1],
            body: options.body,
            paginate: options.paginate,
            json_key: options.json_key,
            json_key_data: options.json_key_data,
            yes: options.yes
          ).run
          STDOUT.puts(output) if output # $stdout may point at stderr, see CLIToolsDistributor
        end
      end

      default_command(:run)

      run!
    end

    def load_supplyfile
      Supply.config.load_configuration_file('Supplyfile')
    end
  end
end
