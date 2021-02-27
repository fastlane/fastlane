require "colored"
require "credentials_manager"

require_relative 'tunes/tunes'
require_relative 'portal/portal'

module Spaceship
  class Playground
    def initialize(username: nil)
      # Make sure the user has pry installed
      begin
        Gem::Specification.find_by_name("pry")
      rescue Gem::LoadError
        puts("Could not find gem 'pry'".red)
        puts("")
        puts("If you installed spaceship using `gem install spaceship` run")
        puts("  gem install pry".yellow)
        puts("to install the missing gem")
        puts("")
        puts("If you use a Gemfile add this to your Gemfile:")
        puts("  gem 'pry'".yellow)
        puts("and run " + "`bundle install`".yellow)

        abort
      end

      require 'pry'

      @username = username
      @username ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)
      @username ||= ask("Username: ")
    end

    def run
      begin
        puts("Logging into to App Store Connect (#{@username})...")
        Spaceship::Tunes.login(@username)
        puts("Successfully logged in to App Store Connect".green)
        puts("")
      rescue
        puts("Could not login to App Store Connect...".red)
      end
      begin
        puts("Logging into the Developer Portal (#{@username})...")
        Spaceship::Portal.login(@username)
        puts("Successfully logged in to the Developer Portal".green)
        puts("")
      rescue
        puts("Could not login to the Developer Portal...".red)
      end

      puts("---------------------------------------".green)
      puts("| Welcome to the spaceship playground |".green)
      puts("---------------------------------------".green)
      puts("")
      puts("Enter #{'docs'.yellow} to open up the documentation")
      puts("Enter #{'exit'.yellow} to exit the spaceship playground")
      puts("Enter #{'_'.yellow} to access the return value of the last executed command")
      puts("")
      puts("Just enter the commands and confirm with Enter".green)

      # rubocop:disable Lint/Debugger
      binding.pry(quiet: true)
      # rubocop:enable Lint/Debugger

      puts("") # Fixes https://github.com/fastlane/fastlane/issues/3493
    end

    def docs
      url = 'https://github.com/fastlane/fastlane/tree/master/spaceship/docs'
      `open '#{url}'`
      url
    end
  end
end
