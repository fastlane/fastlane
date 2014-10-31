# Code climate
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'deliver'
require 'webmock/rspec'

# Own mocking code
require 'mocking/webmocking'
require 'mocking/transporter_mocking'


# This module is only used to check the environment is currently a testing env
module SpecHelper
  
end


module OS
  def self.mac?
    (/darwin/ =~ RUBY_PLATFORM) != nil
  end
end