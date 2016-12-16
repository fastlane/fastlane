require "colored"
require "credentials_manager"
require 'yaml'

module Spaceship
  class SpaceauthRunner
    def initialize(username: nil)
      @username = username
      @username ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)
      @username ||= ask("Username: ")
    end

    def run
      begin
        puts "Logging into to iTunes Connect (#{@username})..."
        Spaceship::Tunes.login(@username)
        puts "Successfully logged in to iTunes Connect".green
        puts ""
      rescue
        puts "Could not login to iTunes Connect...".red
      end

      itc_cookie_content = Spaceship::Tunes.client.store_cookie

      # The only value we actually need is the "DES5c148586daa451e55afb017aa62418f91" cookie
      # We're not sure if the key changes
      #
      # Example:
      # name: DES5c148586daa451e55afb017aa62418f91
      # value: HSARMTKNSRVTWFlaF/ek8asaa9lymMA0dN8JQ6pY7B3F5kdqTxJvMT19EVEFX8EQudB/uNwBHOHzaa30KYTU/eCP/UF7vGTgxs6PAnlVWKscWssOVHfP2IKWUPaa4Dn+I6ilA7eAFQsiaaVT
      cookies = YAML.load(itc_cookie_content)

      # We remove all the un-needed cookies
      cookies.delete_if do |current|
        ['aa', 'X-SESS', 'site', 'acn01', 'myacinfo', 'itctx', 'wosid', 'woinst', 'NSC_17ofu-jud-jud-mc'].include?(current.name)
      end

      yaml = cookies.to_yaml.gsub("\n", "\\n")

      puts "---"
      puts ""
      puts "Pass the following via the FASTLANE_SESSION environment variable:"
      puts yaml.cyan.underline
      puts ""
      puts ""
      puts "Example:"
      puts "export FASTLANE_SESSION='#{yaml}'".cyan.underline
    end
  end
end
