module Spaceship
  class UpdateChecker
    UPDATE_URL = "https://fastlane-refresher.herokuapp.com/spaceship"

    def self.ensure_spaceship_version
      return if defined?(SpecHelper) # is this running via tests
      return if ENV["FASTLANE_SKIP_UPDATE_CHECK"]

      require 'faraday'
      require 'json'

      response = Faraday.get(UPDATE_URL)
      return if response.nil? || response.body.to_s.length == 0

      version = JSON.parse(response.body)["version"]
      puts "Comparing spaceship version (remote #{version} - local #{Spaceship::VERSION})" if $verbose
      return if Gem::Version.new(version) <= Gem::Version.new(Spaceship::VERSION)

      show_update_message(Spaceship::VERSION, version)
    rescue => ex
      puts ex.to_s if $verbose
      puts "Couldn't verify that spaceship is up to date"
    end

    def self.show_update_message(local_version, live_version)
      puts "---------------------------------------------".red
      puts "-------------------WARNING-------------------".red
      puts "---------------------------------------------".red
      puts "You're using an old version of spaceship"
      puts "To ensure spaceship and fastlane works"
      puts "update to the latest version."
      puts ""
      puts "Run `[sudo] gem update spaceship`"
      puts ""
      puts "or `bundle update` if you use bundler."
      puts ""
      puts "You're on spaceship version: #{local_version}".yellow
      puts "Latest spaceship version  : #{live_version}".yellow
      puts ""
    end
  end
end
