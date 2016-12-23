require 'commander'
require 'fastlane/version'

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
      program :help, 'GitHub', 'https://github.com/fastlane/cert'
      program :help_formatter, :compact

      global_option('--verbose') { $verbose = true }

      FastlaneCore::CommanderGenerator.new.generate(Cert::Options.available_options)

      command :create do |c|
        c.syntax = 'cert create'
        c.description = 'Create new iOS code signing certificates'

        c.action do |args, options|
          Cert.config = FastlaneCore::Configuration.create(Cert::Options.available_options, options.__hash__)
          Cert::Runner.new.launch
        end
      end

      command :revoke_expired do |c|
        c.syntax = 'cert revoke_expired'
        c.description = 'Revoke expired iOS code signing certificates'

        c.action do |args, options|
          Cert.config = FastlaneCore::Configuration.create(Cert::Options.available_options, options.__hash__)
          Cert::Runner.new.revoke_expired_certs!
        end
      end

      default_command :create

      run!
    end
  end
end
