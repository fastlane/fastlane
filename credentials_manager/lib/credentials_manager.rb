require 'fastlane/version'
require 'credentials_manager/account_manager'
require 'credentials_manager/cli'
require 'credentials_manager/appfile_config'

# Third Party code
require 'colored'
require 'security'
require 'highline/import' # to hide the entered password

module CredentialsManager
  ROOT = Pathname.new(File.expand_path('../..', __FILE__))
end
