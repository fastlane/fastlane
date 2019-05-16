require 'colored'
require 'credentials_manager/appfile_config'
require 'yaml'

require_relative 'tunes/tunes_client'

module Spaceship
  class SpaceauthRunner
    def initialize(username: nil)
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
        puts("Could not login to App Store Connect".red)
        puts("Please check your credentials and try again.".yellow)
        puts("This could be an issue with App Store Connect,".yellow)
        puts("Please try unsetting the FASTLANE_SESSION environment variable".yellow)
        puts("(if it is set) and re-run `fastlane spaceauth`".yellow)
        raise "Problem connecting to App Store Connect"
      end

      itc_cookie_content = Spaceship::Tunes.client.store_cookie

      # The only value we actually need is the "DES5c148586daa451e55afb017aa62418f91" cookie
      # We're not sure if the key changes
      #
      # Example:
      # name: DES5c148586daa451e55afb017aa62418f91
      # value: HSARMTKNSRVTWFlaF/ek8asaa9lymMA0dN8JQ6pY7B3F5kdqTxJvMT19EVEFX8EQudB/uNwBHOHzaa30KYTU/eCP/UF7vGTgxs6PAnlVWKscWssOVHfP2IKWUPaa4Dn+I6ilA7eAFQsiaaVT
      cookies = YAML.safe_load(
        itc_cookie_content,
        [HTTP::Cookie, Time], # classes whitelist
        [],                   # symbols whitelist
        true                  # allow YAML aliases
      )

      # We remove all the un-needed cookies
      cookies.select! do |cookie|
        cookie.name.start_with?("myacinfo") || cookie.name == 'dqsid'
      end

      yaml = cookies.to_yaml.gsub("\n", "\\n")

      puts("---")
      puts("")
      puts("Pass the following via the FASTLANE_SESSION environment variable:")
      puts(yaml.cyan.underline)
      puts("")
      puts("")
      puts("Example:")
      puts("export FASTLANE_SESSION='#{yaml}'".cyan.underline)

      if mac? && Spaceship::Client::UserInterface.interactive? && agree("🙄 Should fastlane copy the cookie into your clipboard, so you can easily paste it? (y/n)", true)
        require 'open3'
        Open3.popen3('pbcopy') { |input, _, _| input << yaml }
        puts("Successfully copied text into your clipboard 🎨".green)
      end
    end

    def mac?
      (/darwin/ =~ RUBY_PLATFORM) != nil
    end
  end
end
