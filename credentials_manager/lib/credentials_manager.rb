require_relative 'credentials_manager/account_manager'
require_relative 'credentials_manager/cli'
require_relative 'credentials_manager/appfile_config'

module CredentialsManager
  ROOT = Pathname.new(File.expand_path('../..', __FILE__))
end
