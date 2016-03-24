require 'pry'
require 'spaceship'

require 'custom_matchers'

apple_id = ENV['SPACESHIP_INTEGRATION_TEST_APPLE_ID']
password = ENV['SPACESHIP_INTEGRATION_TEST_APPLE_PASSWORD']

unless apple_id && password
  raise "You must set SPACESHIP_INTEGRATION_TEST_APPLE_ID and SPACESHIP_INTEGRATION_TEST_APPLE_PASSWORD environment variables"
end
Spaceship::Portal.login(apple_id, password)
Spaceship::Tunes.login(apple_id, password)
