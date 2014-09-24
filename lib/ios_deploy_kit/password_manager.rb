require 'security'
require 'highline/import' # to hide the entered password

module IosDeployKit
  class PasswordManager
    attr_accessor :username, :password

    HOST = "itunesconnect.apple.com"

    def initialize

      self.username ||= ENV["IOS_DEPLOY_KIT_USER"] || self.load_from_keychain[0]
      self.password ||= ENV["IOS_DEPLOY_KIT_PASSWORD"] || self.load_from_keychain[1]

      if (self.username || '').length == 0 or (self.password || '').length == 0
        ask_for_login
      end
    end

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
      if Security::InternetPassword.add(IosDeployKit::PasswordManager::HOST, self.username, self.password)
        return true
      else
        Helper.log.error "Could not store password in keychain"
        return false
      end
    end
  
    def load_from_keychain
      pass = Security::InternetPassword.find(:server => IosDeployKit::PasswordManager::HOST)
      
      return [pass.attributes['acct'], pass.password] if pass
      return [nil, nil]
    end
  end
end