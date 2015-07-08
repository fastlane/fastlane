require 'commander'
require 'pilot/options'
require 'fastlane_core'

HighLine.track_eof = false

module Pilot
  class CommandsGenerator
    include Commander::Methods

    FastlaneCore::CommanderGenerator.new.generate(Pilot::Options.available_options)

    def self.start
      begin
        FastlaneCore::UpdateChecker.start_looking_for_update('pilot')
        self.new.run
      ensure
        FastlaneCore::UpdateChecker.show_update_status('pilot', Pilot::VERSION)
      end
    end

    def run
      program :version, Pilot::VERSION
      program :description, Pilot::DESCRIPTION
      program :help, 'Author', 'Felix Krause <pilot@krausefx.com>'
      program :help, 'Website', 'https://fastlane.tools'
      program :help, 'GitHub', 'https://github.com/fastlane/pilot'
      program :help_formatter, :compact

      global_option('--verbose') { $verbose = true }

      always_trace!

      command :fly do |c|
        c.syntax = 'pilot'
        c.description = 'Uploads a new binary to Apple TestFlight'
        c.action do |args, options|
          o = options.__hash__.dup
          o.delete(:verbose)
          
          config = FastlaneCore::Configuration.create(Pilot::Options.available_options, o)
          Pilot::Manager.new.run(config)
        end
      end

      default_command :fly

      run!
    end
  end
end