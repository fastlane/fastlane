require "commander"
require "fastlane_core"
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
      program :help, 'GitHub', 'https://github.com/fastlane/fastlane/tree/master/supply'
      program :help_formatter, :compact

      always_trace!

      global_option('--verbose') { FastlaneCore::Globals.verbose = true }

      command :run do |c|
        c.syntax = 'fastlane supply'
        c.description = 'Run a deploy process'

        FastlaneCore::CommanderGenerator.new.generate(Supply::Options.available_options)

        c.action do |args, options|
          Supply.config = FastlaneCore::Configuration.create(Supply::Options.available_options, options.__hash__)
          load_supplyfile

          Supply::Uploader.new.perform_upload
        end
      end

      command :init do |c|
        c.syntax = 'fastlane supply init'
        c.description = 'Sets up supply for you'

        FastlaneCore::CommanderGenerator.new.generate(Supply::Options.available_options)

        c.action do |args, options|
          require 'supply/setup'
          Supply.config = FastlaneCore::Configuration.create(Supply::Options.available_options, options.__hash__)
          load_supplyfile

          Supply::Setup.new.perform_download
        end
      end

      default_command :run

      run!
    end

    def load_supplyfile
      Supply.config.load_configuration_file('Supplyfile')
    end
  end
end
