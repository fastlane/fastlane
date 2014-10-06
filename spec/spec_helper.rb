require 'ios_deploy_kit'
require 'webmock/rspec'
require 'webmocking'


# This module is only used to check the environment is currently a testing env
module SpecHelper
  
end


module OS
  def self.mac?
    (/darwin/ =~ RUBY_PLATFORM) != nil
  end
end