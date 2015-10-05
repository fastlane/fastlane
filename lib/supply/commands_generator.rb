require "commander"
require "fastlane_core"
require "supply"

HighLine.track_eof = false

module Supply
  class CommandsGenerator
    include Commander::Methods

    FastlaneCore::CommanderGenerator.new.generate(Supply::Options.available_options)

    def self.start
      FastlaneCore::UpdateChecker.start_looking_for_update("supply")
      new.run
    ensure
      FastlaneCore::UpdateChecker.show_update_status("supply", Supply::VERSION)
    end

    def run
      program :version, Supply::VERSION
      program :description, 'CLI for \'supply\' - TODO'
      program :help, 'Author', 'Felix Krause <supply@krausefx.com>, Reinhard Hafenscher <TODO>'
      program :help, 'Website', 'https://fastlane.tools'
      program :help, 'GitHub', 'https://github.com/fastlane/supply'
      program :help_formatter, :compact

      always_trace!

      command :run do |c|
        c.syntax = 'supply'
        c.description = 'Run a deploy process'
        c.action do |args, options|
          Supply.config = FastlaneCore::Configuration.create(Supply::Options.available_options, options.__hash__)
          load_gymfile

          Supply::Uploader.new.perform_upload
        end
      end

      command :init do |c|
        c.syntax = 'supply init'
        c.description = 'Sets up supply for you'
        c.action do |args, options|
          require 'supply/setup'
          Supply.config = FastlaneCore::Configuration.create(Supply::Options.available_options, options.__hash__)
          load_gymfile

          Supply::Setup.new.perform_download
        end
      end

      default_command :run

      run!
    end

    def load_gymfile
      Supply.config.load_configuration_file('Supplyfile')
    end
  end
end
