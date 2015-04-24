require 'spaceship'
require 'webmock/rspec'

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

WebMock.disable_net_connect!

ENV["DELIVER_USER"] = "spaceship@krausefx.com"
ENV["DELIVER_PASSWORD"] = "so_secret"

def read_fixture_file(filename)
  File.read(File.join('spec', 'fixtures', filename))
end

RSpec.configure do |config|

  config.before(:each) do

    stub_request(:get, "https://developer.apple.com/devcenter/ios/index.action").
      to_return(:status => 200, :body => read_fixture_file("landing_page.html"), :headers => {})

    stub_request(:post, "https://idmsa.apple.com/IDMSWebAuth/authenticate").
      with(:body => {"accountPassword"=>"so_secret", "appIdKey"=>"2089349823abbababa98239839", "appleId"=>"spaceship@krausefx.com"},
           :headers => {'Content-Type'=>'application/x-www-form-urlencoded'}).
      to_return(:status => 200, :body => "", :headers => {'Set-Cookie' => "myacinfo=abcdef;"})

    stub_request(:post, 'https://developer.apple.com/services-account/QH65B2/account/listTeams.action').
      with(:body => {}, :headers => {'Cookie' => 'myacinfo=abcdef;'}).
      to_return(:status => 200, :body => read_fixture_file('listTeams.action.json'), :headers => {'Content-Type' => 'application/json'})

    stub_request(:post, 'https://developer.apple.com/services-account/QH65B2/account/ios/identifiers/listAppIds.action').
      with(:body => {:teamId => 'XXXXXXX', :pageSize => 500, :pageNumber => 1, :sort => 'name=asc'}, :headers => {'Cookie' => 'myacinfo=abcdef;'}).
      to_return(:status => 200, :body => read_fixture_file('listTeams.action.json'), :headers => {'Content-Type' => 'application/json'})
  end
end
