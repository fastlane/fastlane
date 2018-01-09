require 'commander'

require_relative 'account_manager'

module CredentialsManager
  class CLI
    include Commander::Methods

    # Parses command options and executes actions
    def run
      program :name, 'CredentialsManager'
      program :version, Fastlane::VERSION
      program :description, 'Manage credentials for fastlane tools.'

      # Command to add entry to Keychain
      command :add do |c|
        c.syntax = 'fastlane fastlane-credentials add'
        c.description = 'Adds a fastlane credential to the keychain.'

        c.option('--username username', String, 'Username to add.')
        c.option('--password password', String, 'Password to add.')

        c.action do |args, options|
          username = options.username || ask('Username: ')
          password = options.password || ask('Password: ') { |q| q.echo = '*' }

          add(username, password)

          puts("Credential #{username}:#{'*' * password.length} added to keychain.")
        end
      end

      # Command to remove credential from Keychain
      command :remove do |c|
        c.syntax = 'fastlane fastlane-credentials remove'
        c.description = 'Removes a fastlane credential from the keychain.'

        c.option('--username username', String, 'Username to remove.')

        c.action do |args, options|
          username = options.username || ask('Username: ')

          remove(username)
        end
      end

      run!
    end

    private

    # Add entry to Apple Keychain using AccountManager
    def add(username, password)
      CredentialsManager::AccountManager.new(
        user: username,
        password: password
      ).add_to_keychain
    end

    # Remove entry from Apple Keychain using AccountManager
    def remove(username)
      CredentialsManager::AccountManager.new(
        user: username
      ).remove_from_keychain
    end
  end
end
