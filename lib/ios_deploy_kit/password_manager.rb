require 'security'
require 'highline/import' # to hide the entered password

module IosDeployKit
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
      self.username ||= ENV["IOS_DEPLOY_KIT_USER"] || load_from_keychain[0]
      self.password ||= ENV["IOS_DEPLOY_KIT_PASSWORD"] || load_from_keychain[1]

      if (self.username || '').length == 0 or (self.password || '').length == 0
        ask_for_login
      end
    end

    private
      def ask_for_login
        puts "No username or password given. You can use environment variables"
        puts "IOS_DEPLOY_KIT_USER, IOS_DEPLOY_KIT_PASSWORD"
        puts "The login information will be stored in your keychain"

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
    
      def load_from_keychain
        pass = Security::InternetPassword.find(:server => HOST)
        
        return [pass.attributes['acct'], pass.password] if pass
        return [nil, nil]
      end
  end
end