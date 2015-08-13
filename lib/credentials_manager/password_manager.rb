require 'security'
require 'highline/import' # to hide the entered password
require 'credentials_manager/appfile_config'

module CredentialsManager
  # Handles reading out the password from the keychain or asking for login data
  class PasswordManager
    # @return [String] The username / email address of the currently logged in user
    attr_accessor :username
    # @return [String] The password of the currently logged in user
    attr_accessor :password

    HOST = "deliver" # there might be a string appended, if user has multiple accounts
    private_constant :HOST

    # A singleton object, which also makes sure, to use the correct Apple ID
    # @param id_to_use (String) The Apple ID email address which should be used
    # @param ask_if_missing (boolean) true by default: if no credentials are found, should the user be asked?
    def self.shared_manager(id_to_use = nil, ask_if_missing = true)
      @instance ||= {}
      return @instance[id_to_use] if @instance[id_to_use]
      if id_to_use
        @instance[id_to_use] ||= PasswordManager.new(id_to_use, ask_if_missing)
      else
        # No user given, let's see if we have a previously used one
        return @instance.values.first if @instance.values.count > 0

        # Create a new one
        @instance[id_to_use] ||= PasswordManager.new(id_to_use, ask_if_missing)
      end
    end

    def self.logout
      @instance = nil
    end

    # A new instance of PasswordManager.
    # 
    # This already check the Keychain if there is a username and password stored.
    # If that's not the case, it will ask for login data via stdin
    # @param id_to_use (String) Apple ID (e.g. user@apple.com) which should be used for this upload.
    #  if given, only the password will be asked/loaded.
    # @param ask_if_missing (boolean) true by default: if no credentials are found, should the user be asked?
    def initialize(id_to_use = nil, ask_if_missing = true)
      
      self.username ||= id_to_use || ENV["DELIVER_USER"] || AppfileConfig.try_fetch_value(:apple_id) || load_from_keychain[0]
      self.password ||= ENV["DELIVER_PASSWORD"] || load_from_keychain[1]

      if (self.username || '').length == 0 or (self.password || '').length == 0
        if ask_if_missing
          puts "No username or password given. You can set environment variables:"
          puts "DELIVER_USER, DELIVER_PASSWORD"

          ask_for_login
        end
      end
    end

    # This method is called, when the iTunes backend returns that the login data is wrong
    # This will ask the user, if he wants to re-enter the password
    def password_seems_wrong
      puts "It seems like the username or password for the account '#{self.username}' is wrong.".red
      puts "Please open the Keychain app, switch to `Passwords` and search for `deliver.`".red
      puts "You can then either remove the outdated entry or directly update it.".red
    end

    private
      def ask_for_login
        puts "-------------------------------------------------------------------------------------".green
        puts "The login information you enter will be stored in your Mac OS Keychain".green
        puts "More information about that on GitHub: https://github.com/fastlane/CredentialsManager".green
        puts "-------------------------------------------------------------------------------------".green

        username_was_there = self.username

        while (self.username || '').length == 0
          self.username = ask("Username: ")
        end

        self.password ||= load_from_keychain[1] # maybe there was already something stored in the keychain

        if (self.password || '').length > 0
          return true
        else
          while (self.password || '').length == 0
            text = "Password: "
            text = "Password (for #{self.username}): " if username_was_there
            self.password = ask(text) { |q| q.echo = "*" }
          end

          # Now we store this information in the keychain
          # Example usage taken from https://github.com/nomad/cupertino/blob/master/lib/cupertino/provisioning_portal/commands/login.rb
          unless ENV["FASTLANE_DONT_STORE_PASSWORD"]
            if Security::InternetPassword.add(hostname, self.username, self.password)
              return true
            else
              puts "Could not store password in keychain".red
              return false
            end
          end
        end
      end

      def remove_from_keychain
        puts "Removing keychain item: #{hostname}".yellow
        Security::InternetPassword.delete(:server => hostname)
      end
    
      def load_from_keychain
        pass = Security::InternetPassword.find(:server => hostname)
        
        return [pass.attributes['acct'], pass.password] if pass
        return [nil, nil]
      end

      def hostname
        [HOST, self.username].join('.')
      end
  end
end
