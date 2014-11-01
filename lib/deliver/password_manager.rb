require 'security'
require 'highline/import' # to hide the entered password

module Deliver
  # Handles reading out the password from the keychain or asking for login data
  class PasswordManager
    # @return [String] The username / email address of the currently logged in user
    attr_accessor :username
    # @return [String] The password of the currently logged in user
    attr_accessor :password

    HOST = "itunesconnect.apple.com"
    private_constant :HOST

    # A new instance of PasswordManager.
    # 
    # This already check the Keychain if there is a username and password stored.
    # If that's not the case, it will ask for login data via stdin
    def initialize
      self.username ||= ENV["DELIVER_USER"] || load_from_keychain[0]
      self.password ||= ENV["DELIVER_PASSWORD"] || load_from_keychain[1]

      if (self.username || '').length == 0 or (self.password || '').length == 0
        puts "No username or password given. You can set environment variables:"
        puts "DELIVER_USER, DELIVER_PASSWORD"

        ask_for_login
      end
    end

    # This method is called, when the iTunes backend returns that the login data is wrong
    # This will ask the user, if he wants to re-enter the password
    def password_seems_wrong
      return false if Helper.is_test?
      
      puts "It seems like the username or password for the account '#{self.username}' is wrong."
      reenter = agree("Do you want to re-enter your username and password? (y/n)", true)
      if reenter
        @username = nil
        @password = nil
        remove_from_keychain

        puts "You will have to re-run the recent command to use the new username/password."
        return true
      else
        return false
      end
    end

    private
      def ask_for_login
        puts "--------------------------------------------------------------------------".green
        puts "The login information you enter now will be stored in your keychain       ".green
        puts "More information about that on GitHub: https://github.com/krausefx/deliver".green
        puts "--------------------------------------------------------------------------".green

        while (self.username || '').length == 0
          self.username = ask("Username: ")
        end

        while (self.password || '').length == 0
          self.password = ask("Password: ") { |q| q.echo = "*" }
        end

        # Now we store this information in the keychain
        # Example usage taken from https://github.com/nomad/cupertino/blob/master/lib/cupertino/provisioning_portal/commands/login.rb
        if Security::InternetPassword.add(HOST, self.username, self.password)
          return true
        else
          Helper.log.error "Could not store password in keychain"
          return false
        end
      end

      def remove_from_keychain
        Security::InternetPassword.delete(:server => HOST)
      end
    
      def load_from_keychain
        pass = Security::InternetPassword.find(:server => HOST)
        
        return [pass.attributes['acct'], pass.password] if pass
        return [nil, nil]
      end
  end
end