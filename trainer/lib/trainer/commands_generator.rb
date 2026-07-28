require 'commander'

require 'fastlane_core/configuration/configuration'
require 'fastlane_core/ui/help_formatter'

require_relative 'options'
require_relative 'test_parser'

require_relative 'module'

HighLine.track_eof = false

module Trainer
  class CommandsGenerator
    include Commander::Methods

    def self.start
      self.new.run
    end

    def run
      program :version, Fastlane::VERSION
      program :description, Trainer::DESCRIPTION
      program :help, 'Author', 'Felix Krause <trainer@krausefx.com>'
      program :help, 'Website', 'https://fastlane.tools'
      program :help, 'GitHub', 'https://github.com/KrauseFx/trainer'
      program :help_formatter, :compact

      global_option('--verbose', 'Shows a more verbose output') { $verbose = true }

      always_trace!

      FastlaneCore::CommanderGenerator.new.generate(Trainer::Options.available_options)

      command :run do |c|
        c.syntax = 'trainer'
        c.description = Trainer::DESCRIPTION

        c.action do |args, options|
          options = FastlaneCore::Configuration.create(Trainer::Options.available_options, options.__hash__)
          FastlaneCore::PrintTable.print_values(config: options, title: "Summary for trainer #{Fastlane::VERSION}") if $verbose
          Trainer::TestParser.auto_convert(options)
        end
      end

      default_command(:run)

      run!
    end
  end
end
