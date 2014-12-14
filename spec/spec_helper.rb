# Code climate
require 'credentials_manager'


ENV["DELIVER_USER"] = "felix@sunapps.net"
# ENV["DELIVER_PASSWORD"] = "DELIVERPASS"

# This module is only used to check the environment is currently a testing env
module SpecHelper
  
end


module OS
  def self.mac?
    (/darwin/ =~ RUBY_PLATFORM) != nil
  end
end