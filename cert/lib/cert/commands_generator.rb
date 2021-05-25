require 'commander'
require 'fastlane/version'
require 'fastlane_core/ui/help_formatter'
require 'fastlane_core/configuration/configuration'
require 'fastlane_core/globals'

require_relative 'options'
require_relative 'runner'

HighLine.track_eof = false

module Cert
  class CommandsGenerator
    include Commander::Methods

    def self.start
      self.new.run
    end

    def run
      program :name, 'cert'
      program :version, Fastlane::VERSION
      program :description, 'CLI for \'cert\' - Create new iOS code signing certificates'
      program :help, 'Author', 'Felix Krause <cert@krausefx.com>'
      program :help, 'Website', 'https://fastlane.tools'
      program :help, 'Documentation', 'https://docs.fastlane.tools/actions/cert/'
      program :help_formatter, FastlaneCore::HelpFormatter

      global_option('--verbose') { FastlaneCore::Globals.verbose = true }
      global_option('--env STRING[,STRING2]', String, 'Add environment(s) to use with `dotenv`')

      command :create do |c|
        c.syntax = 'fastlane cert create'
        c.description = 'Create new iOS code signing certificates'

        FastlaneCore::CommanderGenerator.new.generate(Cert::Options.available_options, command: c)

        c.action do |args, options|
          Cert.config = FastlaneCore::Configuration.create(Cert::Options.available_options, options.__hash__)
          Cert::Runner.new.launch
        end
      end

      command :revoke_expired do |c|
        c.syntax = 'fastlane cert revoke_expired'
        c.description = 'Revoke expired iOS code signing certificates'

        FastlaneCore::CommanderGenerator.new.generate(Cert::Options.available_options, command: c)

        c.action do |args, options|
          Cert.config = FastlaneCore::Configuration.create(Cert::Options.available_options, options.__hash__)
          Cert::Runner.new.revoke_expired_certs!
        end
      end

      default_command(:create)

      run!
    end
  end
end
