require 'security'
require 'highline/import' # to hide the entered password

require_relative 'appfile_config'

module CredentialsManager
  class AccountManager
    DEFAULT_PREFIX = "deliver"
    # @param prefix [String] Very optional, is used for the
    #   iTunes Transporter which uses application specific passwords
    # @param note [String] An optional note that will be shown next
    #   to the password and username prompt
    def initialize(user: nil, password: nil, prefix: nil, note: nil)
      @prefix = prefix || DEFAULT_PREFIX

      @user = user
      @password = password
      @note = note
    end

    # Is the default prefix "deliver"
    def default_prefix?
      @prefix == DEFAULT_PREFIX
    end

    def user
      if default_prefix?
        @user ||= ENV["FASTLANE_USER"]
        @user ||= ENV["DELIVER_USER"]
        @user ||= AppfileConfig.try_fetch_value(:apple_id)
      end

      ask_for_login if @user.to_s.length == 0
      return @user
    end

    def fetch_password_from_env
      password = ENV["FASTLANE_PASSWORD"] || ENV["DELIVER_PASSWORD"]
      return password if password.to_s.length > 0
      return nil
    end

    def password(ask_if_missing: true)
      if default_prefix?
        @password ||= fetch_password_from_env
      end

      unless @password
        item = Security::InternetPassword.find(server: server_name)
        @password ||= item.password if item
      end
      ask_for_login while ask_if_missing && @password.to_s.length == 0
      return @password
    end

    # Call this method to ask the user to re-enter the credentials
    # @param force: if false, the user is asked before it gets deleted
    # @return: Did the user decide to remove the old entry and enter a new password?
    def invalid_credentials(force: false)
      puts("The login credentials for '#{user}' seem to be wrong".red)

      if fetch_password_from_env
        puts("The password was taken from the environment variable")
        puts("Please make sure it is correct")
        return false
      end

      if force || agree("Do you want to re-enter your password? (y/n)", true)
        puts("Removing Keychain entry for user '#{user}'...".yellow)
        remove_from_keychain
        ask_for_login
        return true
      end
      false
    end

    def add_to_keychain
      if options
        Security::InternetPassword.add(server_name, user, password, options)
      else
        Security::InternetPassword.add(server_name, user, password)
      end
    end

    def remove_from_keychain
      Security::InternetPassword.delete(server: server_name)
      @password = nil
    end

    def server_name
      "#{@prefix}.#{user}"
    end

    # Use env variables from this method to augment internet password item with additional data.
    # These variables are used by Xamarin Studio to authenticate Apple developers.
    def options
      hash = {}
      hash[:p] = ENV["FASTLANE_PATH"] if ENV["FASTLANE_PATH"]
      hash[:P] = ENV["FASTLANE_PORT"] if ENV["FASTLANE_PORT"]
      hash[:r] = ENV["FASTLANE_PROTOCOL"] if ENV["FASTLANE_PROTOCOL"]
      hash.empty? ? nil : hash
    end

    private

    def ask_for_login
      if ENV["FASTLANE_HIDE_LOGIN_INFORMATION"].to_s.length == 0
        puts("-------------------------------------------------------------------------------------".green)
        puts("Please provide your Apple Developer Program account credentials".green)
        puts("The login information you enter will be stored in your macOS Keychain".green)
        if default_prefix?
          # We don't want to show this message, if we ask for the application specific password
          # which has a different prefix
          puts("You can also pass the password using the `FASTLANE_PASSWORD` environment variable".green)
          puts("See more information about it on GitHub: https://github.com/fastlane/fastlane/tree/master/credentials_manager".green)
        end
        puts("-------------------------------------------------------------------------------------".green)
      end

      if @user.to_s.length == 0
        raise "Missing username, and running in non-interactive shell" if $stdout.isatty == false
        prompt_text = "Username"
        prompt_text += " (#{@note})" if @note
        prompt_text += ": "
        @user = ask(prompt_text) while @user.to_s.length == 0
        # Returning here since only the username was asked for. This method will be called again when a password is needed.
        return
      end

      while @password.to_s.length == 0
        raise "Missing password for user #{@user}, and running in non-interactive shell" if $stdout.isatty == false
        note = @note + " " if @note
        @password = ask("Password (#{note}for #{@user}): ") { |q| q.echo = "*" }
      end

      return true if ENV["FASTLANE_DONT_STORE_PASSWORD"]
      return true if (/darwin/ =~ RUBY_PLATFORM).nil? # mac?, since we don't have access to the helper here

      # Now we store this information in the keychain
      if add_to_keychain
        return true
      else
        puts("Could not store password in keychain".red)
        return false
      end
    end
  end
end
