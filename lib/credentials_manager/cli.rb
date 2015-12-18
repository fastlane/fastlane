require 'credentials_manager/version'
require 'commander'

module CredentialsManager
  class CLI
    include Commander::Methods

    # Parses command options and executes actions
    def run
      program :name, 'CredentialsManager'
      program :version, ::CredentialsManager::VERSION
      program :description, 'Manage credentials for fastlane tools.'

      # Command to add entry to Keychain
      command :add do |c|
        c.syntax = 'fastlane-credentials add'
        c.description = 'Adds a fastlane credential to the keychain.'

        c.option '--username username', String, 'Username to add.'
        c.option '--password password', String, 'Password to add.'

        c.action do |args, options|
          username, password = options.username, options.password

          if username.nil?
            raise 'You must specify a username'
          elsif password.nil?
            raise 'You must specify a password'
          else
            add(username, password)

            puts "Credential #{username}:#{'*' * password.length} added to keychain."
          end

        end
      end

      # Command to remove credential from Keychain
      command :remove do |c|
        c.syntax = 'fastlane-credentials remove'
        c.description = 'Removes a fastlane credential from the keychain.'

        c.option '--username username', String, 'Username to remove.'

        c.action do |args, options|
          username = options.username

          if username.nil?
            raise 'You must specify a username'
          else
            remove(username)
          end
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
