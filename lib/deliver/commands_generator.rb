require 'commander'
require 'deliver/download_screenshots'

HighLine.track_eof = false

module Deliver
  class CommandsGenerator
    include Commander::Methods

    def self.start
      begin
        # FastlaneCore::UpdateChecker.start_looking_for_update('deliver')
        # Deliver::DependencyChecker.check_dependencies
        self.new.run
      ensure
        # FastlaneCore::UpdateChecker.show_update_status('deliver', Deliver::VERSION)
      end
    end

    def run
      program :version, Deliver::VERSION
      program :description, Deliver::DESCRIPTION
      program :help, 'Author', 'Felix Krause <deliver@krausefx.com>'
      program :help, 'Website', 'https://fastlane.tools'
      program :help, 'GitHub', 'https://github.com/krausefx/deliver'
      program :help_formatter, :compact

      FastlaneCore::CommanderGenerator.new.generate(Deliver::Options.available_options)

      global_option('--verbose') { $verbose = true }

      always_trace!

      command :run do |c|
        c.syntax = 'deliver'
        c.description = 'Upload metadata and binary to iTunes Connect'
        c.action do |args, options|
          options = FastlaneCore::Configuration.create(Deliver::Options.available_options, options.__hash__)
          options.load_configuration_file("Deliverfile")
          Deliver::Manager.new.run(options)          
        end
      end

      default_command :run

      run!
    end
    
  end
end
