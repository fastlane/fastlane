require 'commander'

require 'fastlane/version'
require 'fastlane_core/configuration/configuration'
require 'fastlane_core/ui/help_formatter'
require_relative 'options'
require_relative 'manager'

HighLine.track_eof = false

module PEM
  class CommandsGenerator
    include Commander::Methods

    def self.start
      self.new.run
    end

    def run
      program :name, 'pem'
      program :version, Fastlane::VERSION
      program :description, 'CLI for \'PEM\' - Automatically generate and renew your push notification profiles'
      program :help, 'Author', 'Felix Krause <pem@krausefx.com>'
      program :help, 'Website', 'https://fastlane.tools'
      program :help, 'Documentation', 'https://docs.fastlane.tools/actions/pem/'
      program :help_formatter, FastlaneCore::HelpFormatter

      global_option('--verbose') { FastlaneCore::Globals.verbose = true }
      global_option('--env STRING[,STRING2]', String, 'Add environment(s) to use with `dotenv`')

      command :renew do |c|
        c.syntax = 'fastlane pem renew'
        c.description = 'Renews the certificate (in case it expired) and shows the path to the generated pem file'

        FastlaneCore::CommanderGenerator.new.generate(PEM::Options.available_options, command: c)

        c.action do |args, options|
          PEM.config = FastlaneCore::Configuration.create(PEM::Options.available_options, options.__hash__)
          PEM::Manager.start
        end
      end

      default_command(:renew)

      run!
    end
  end
end
