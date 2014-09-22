require 'security'

module IosDeployKit
  class PasswordManager
    attr_accessor :username, :password

    HOST = "itunesconnect.apple.com"

    def initialize

      self.username ||= ENV["IOS_DEPLOY_KIT_USER"] || self.load_from_keychain[0]
      self.password ||= ENV["IOS_DEPLOY_KIT_PASSWORD"] || self.load_from_keychain[1]

    end

  
    def load_from_keychain
      pass = Security::InternetPassword.find(:server => IosDeployKit::PasswordManager::HOST)
      
      return [pass.attributes['acct'], pass.password] if pass
      return [nil, nil]
    end
  end
end