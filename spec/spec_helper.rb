require 'sigh'
require 'webmock/rspec'
require 'stubbing.rb'

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

WebMock.disable_net_connect!
