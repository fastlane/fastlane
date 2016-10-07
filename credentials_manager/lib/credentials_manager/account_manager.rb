require 'security'
require 'highline/import' # to hide the entered password

module CredentialsManager
  class AccountManager
    # @param prefix [String] Very optional, is used for the
    #   iTunes Transporter which uses application specofic passwords
    def initialize(user: nil, password: nil, prefix: nil)
      @prefix = prefix || "deliver"

      @user = user
      @password = password
    end

    def user
      @user ||= ENV["FASTLANE_USER"]
      @user ||= ENV["DELIVER_USER"]
      @user ||= AppfileConfig.try_fetch_value(:apple_id)
      ask_for_login if @user.to_s.length == 0
      return @user
    end

    def fetch_password_from_env
      ENV["FASTLANE_PASSWORD"] || ENV["DELIVER_PASSWORD"]
    end

    def password(ask_if_missing: true)
      @password ||= fetch_password_from_env
      unless @password
        item = Security::InternetPassword.find(server: server_name)
        @password ||= item.password if item
      end
      ask_for_login while ask_if_missing && @password.to_s.length == 0
      return @password
    end

    # Call this method to ask the user to re-enter the credentials
    # @param force: if false the user is asked before it gets deleted
    # @return: Did the user decide to remove the old entry and enter a new password?
    def invalid_credentials(force: false)
      puts "The login credentials for '#{user}' seem to be wrong".red

      if fetch_password_from_env
        puts "The password was taken from the environment variable"
        puts "Please make sure it is correct"
        return false
      end

      if force || agree("Do you want to re-enter your password? (y/n)", true)
        puts "Removing Keychain entry for user '#{user}'...".yellow
        remove_from_keychain
        ask_for_login
        return true
      end
      false
    end

    def add_to_keychain
      Security::InternetPassword.add(server_name, user, password)
    end

    def remove_from_keychain
      Security::InternetPassword.delete(server: server_name)
      @password = nil
    end

    def server_name
      "#{@prefix}.#{user}"
    end

    private

    def ask_for_login
      puts "-------------------------------------------------------------------------------------".green
      puts "The login information you enter will be stored in your Mac OS Keychain".green
      puts "You can also pass the password using the `FASTLANE_PASSWORD` environment variable".green
      puts "More information about it on GitHub: https://github.com/fastlane/fastlane/tree/master/credentials_manager".green
      puts "-------------------------------------------------------------------------------------".green

      if @user.to_s.length == 0
        raise "Missing username, and running in non-interactive shell" if $stdout.isatty == false
        @user = ask("Username: ") while @user.to_s.length == 0
        # we return here, as only the username was asked for now, we'll get called for the pw again anyway
        return
      end

      while @password.to_s.length == 0
        raise "Missing password for user #{@user}, and running in non-interactive shell" if $stdout.isatty == false
        @password = ask("Password (for #{@user}): ") { |q| q.echo = "*" }
      end

      return true if ENV["FASTLANE_DONT_STORE_PASSWORD"]
      return true if (/darwin/ =~ RUBY_PLATFORM).nil? # mac?, since we don't have access to the helper here

      # Now we store this information in the keychain
      if add_to_keychain
        return true
      else
        puts "Could not store password in keychain".red
        return false
      end
    end
  end
end
