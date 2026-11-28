require 'highline'

HighLine.track_eof = false

require 'fastlane/version'
require 'fastlane_core/ui/help_formatter'
require_relative 'playground'
require_relative 'spaceauth_runner'
require_relative 'api_runner'

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
        c.option('--copy_to_clipboard VALUE', 'Whether the session string should be copied to clipboard (true/false). For more info see https://docs.fastlane.tools/best-practices/continuous-integration/#storing-a-manually-verified-session-using-spaceauth`')
        c.option('--check_session', 'Check to see if there is a valid session (either in the cache or via FASTLANE_SESSION). Sets the exit code to 0 if the session is valid or 1 if not.') { Spaceship::Globals.check_session = true }
        c.action do |args, options|
          copy_to_clipboard = if options.copy_to_clipboard.nil?
                                nil
                              elsif %w(yes YES true TRUE on ON).include?(options.copy_to_clipboard.to_s)
                                true
                              elsif %w(no NO false FALSE off OFF).include?(options.copy_to_clipboard.to_s)
                                false
                              end
          Spaceship::SpaceauthRunner.new(username: options.user, copy_to_clipboard: copy_to_clipboard).run
        end
      end

      command :api do |c|
        c.syntax = 'fastlane spaceship api <METHOD> <PATH> [options]'
        c.description = "Send one App Store Connect API request and print Apple's JSON response"
        c.option('--body JSON', String, 'Request body: JSON text, or @path to a JSON file')
        c.option('--paginate', 'Follow links.next and print all pages as one response (GET only)')
        c.option('--api_key_path PATH', String, 'App Store Connect API key JSON file. Without it, the SPACESHIP_CONNECT_API_* environment variables, else an Apple ID login (-u)')
        c.option('--yes', 'Confirm a DELETE request')
        c.example('List apps', 'fastlane spaceship api GET "/v1/apps?limit=200" --paginate --api_key_path key.json')
        c.example('Rename a beta group', 'fastlane spaceship api PATCH /v1/betaGroups/123 --body @rename.json')

        c.action do |args, options|
          FastlaneCore::UI.user_error!("Usage: #{c.syntax}") unless args.size == 2
          output = Spaceship::ApiRunner.new(
            method: args[0],
            path: args[1],
            body: options.body,
            paginate: options.paginate,
            api_key_path: options.api_key_path,
            username: options.user,
            yes: options.yes
          ).run
          STDOUT.puts(output) if output # $stdout may point at stderr, see CLIToolsDistributor
        end
      end

      default_command(:playground)

      run!
    end
  end
end
