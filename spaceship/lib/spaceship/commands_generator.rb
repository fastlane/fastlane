require 'highline'

HighLine.track_eof = false

require 'fastlane/version'
require 'fastlane_core/ui/help_formatter'
require_relative 'playground'
require_relative 'spaceauth_runner'

module Spaceship
  class CommandsGenerator
    include Commander::Methods

    def self.start
      self.new.run
    end

    def run
      program :name, 'spaceship'
      program :version, Fastlane::VERSION
      program :description, Spaceship::DESCRIPTION
      program :help, 'Author', 'Felix Krause <spaceship@krausefx.com>'
      program :help, 'Website', 'https://fastlane.tools'
      program :help, 'GitHub', 'https://github.com/fastlane/fastlane/tree/master/spaceship'
      program :help_formatter, FastlaneCore::HelpFormatter

      global_option('-u', '--user USERNAME', 'Specify the Apple ID you want to log in with')
      global_option('--verbose') { FastlaneCore::Globals.verbose = true }
      global_option('--env STRING[,STRING2]', String, 'Add environment(s) to use with `dotenv`')

      command :playground do |c|
        c.syntax = 'fastlane spaceship playground'
        c.description = 'Run an interactive shell that connects you to Apple web services'

        c.action do |args, options|
          Spaceship::Playground.new(username: options.user).run
        end
      end

      command :spaceauth do |c|
        c.syntax = 'fastlane spaceship spaceauth'
        c.description = 'Authentication helper for spaceship/fastlane to work with Apple 2-Step/2FA'
        c.option('--copy_to_clipboard', 'Whether the session string should be copied to clipboard. For more info see https://docs.fastlane.tools/best-practices/continuous-integration/#storing-a-manually-verified-session-using-spaceauth`')
        c.option('--check_session', 'Check to see if there is a valid session (either in the cache or via FASTLANE_SESSION). Sets the exit code to 0 if the session is valid or 1 if not.') { Spaceship::Globals.check_session = true }
        c.action do |args, options|
          Spaceship::SpaceauthRunner.new(username: options.user, copy_to_clipboard: options.copy_to_clipboard).run
        end
      end

      default_command(:playground)

      run!
    end
  end
end
