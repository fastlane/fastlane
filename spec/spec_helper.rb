# Code climate
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

# This module is only used to check the environment is currently a testing env
# Needs to be above the `require 'deliver'`
module SpecHelper
  
end

require 'deliver'
require 'webmock/rspec'

# Own mocking code
require 'mocking/webmocking'
require 'mocking/transporter_mocking'


ENV["DELIVER_USER"] = "DELIVERUSER"
ENV["DELIVER_PASSWORD"] = "DELIVERPASS"



RSpec.configure do |config|
  config.after(:each) do |test|
    count = Deliver::ItunesTransporter.number_of_mock_files
    Deliver::ItunesTransporter.clear_mock_files
    raise "Looks like there were too many mock files set in the Deliver::ItunesTransporter in this test: '#{test.metadata[:example_group][:full_description]}'" if count > 0
  end
end