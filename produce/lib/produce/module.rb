require 'fastlane_core/helper'
require 'spaceship'

module Produce
  class << self
    attr_accessor :config
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  ROOT = Pathname.new(File.expand_path('../../..', __FILE__))

  ENV['FASTLANE_TEAM_ID'] ||= ENV["PRODUCE_TEAM_ID"]
  ENV['DELIVER_USER'] ||= ENV["PRODUCE_USERNAME"]

  # Shared by DeveloperCenter#login and Service#bundle_id. Prefers a configured API key, falls
  # back to a token already set by another lane (e.g. app_store_connect_api_key), then falls
  # back to username-based session login.
  def self.authenticate_connect_api!
    if (token = Spaceship::ConnectAPI::Token.from(hash: Produce.config[:api_key], filepath: Produce.config[:api_key_path]))
      UI.message("Authenticating with App Store Connect API Key")

      # `current_team_id:` avoids a live, session-based team_id lookup elsewhere in
      # ConnectAPI's provisioning client, which has no session to use here.
      Spaceship::ConnectAPI.client = Spaceship::ConnectAPI::Client.new(token: token, current_team_id: Produce.config[:team_id])
    elsif !Spaceship::ConnectAPI.token.nil?
      UI.message("Using existing authorization token for App Store Connect API")
    else
      UI.message("Starting login with user '#{Produce.config[:username]}'")
      Spaceship.login(Produce.config[:username], nil)
      Spaceship.select_team
      UI.message("Successfully logged in")
    end
  end
end
