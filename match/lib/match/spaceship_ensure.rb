require 'spaceship'
require_relative 'module'
require_relative 'portal_fetcher'

module Match
  # Ensures the certificate and profiles are also available on App Store Connect
  class SpaceshipEnsure
    attr_accessor :team_id

    def initialize(user, team_id, team_name, api_token)
      UI.message("Verifying that the certificate and profile are still valid on the Dev Portal...")

      if api_token
        UI.message("Creating authorization token for App Store Connect API")
        Spaceship::ConnectAPI.token = api_token
        self.team_id = team_id
      elsif !Spaceship::ConnectAPI.token.nil?
        UI.message("Using existing authorization token for App Store Connect API")
        self.team_id = team_id
      else
        # We'll try to manually fetch the password
        # to tell the user that a password is optional
        require 'credentials_manager/account_manager'

        keychain_entry = CredentialsManager::AccountManager.new(user: user)

        if keychain_entry.password(ask_if_missing: false).to_s.length == 0
          UI.important("You can also run `fastlane match` in readonly mode to not require any access to the")
          UI.important("Developer Portal. This way you only share the keys and credentials")
          UI.command("fastlane match --readonly")
          UI.important("More information https://docs.fastlane.tools/actions/match/#access-control")
        end

        # Prompts select team if multiple teams and none specified
        Spaceship::ConnectAPI.login(user, use_portal: true, use_tunes: false, portal_team_id: team_id, team_name: team_name)
        self.team_id = Spaceship::ConnectAPI.client.portal_team_id
      end
    end

    # The team ID of the currently logged in team
    def team_id
      return @team_id
    end

    def bundle_identifier_exists(username: nil, app_identifier: nil, cached_bundle_ids: nil)
      search_bundle_ids = cached_bundle_ids || Match::Portal::Fetcher.bundle_ids(bundle_id_identifiers: [app_identifier])
      found = search_bundle_ids.any? { |bundle_id| bundle_id.identifier == app_identifier }
      return if found

      require 'sigh/runner'
      Sigh::Runner.new.print_produce_command({
        username: username,
        app_identifier: app_identifier
      })
      UI.error("An app with that bundle ID needs to exist in order to create a provisioning profile for it")
      UI.error("================================================================")
      all_bundle_ids = Match::Portal::Fetcher.bundle_ids
      available_apps = all_bundle_ids.collect { |a| "#{a.identifier} (#{a.name})" }
      UI.message("Available apps:\n- #{available_apps.join("\n- ")}")
      UI.error("Make sure to run `fastlane match` with the same user and team every time.")
      UI.user_error!("Couldn't find bundle identifier '#{app_identifier}' for the user '#{username}'")
    end

    def certificates_exists(username: nil, certificate_ids: [], platform:, profile_type:, cached_certificates:)
      certificates = cached_certificates
      certificates ||= Match::Portal::Fetcher.certificates(platform: platform, profile_type: profile_type)
      certificates.each do |cert|
        certificate_ids.delete(cert.id)
      end
      return if certificate_ids.empty?

      certificate_ids.each do |certificate_id|
        UI.error("Certificate '#{certificate_id}' (stored in your storage) is not available on the Developer Portal")
      end
      UI.error("for the user #{username}")
      UI.error("Make sure to use the same user and team every time you run 'match' for this")
      UI.error("Git repository. This might be caused by revoking the certificate on the Dev Portal")
      UI.error("If missing certificate is a Developer ID Installer, you may need to auth with Apple ID instead of App Store API Key")
      UI.user_error!("To reset the certificates of your Apple account, you can use the `fastlane match nuke` feature, more information on https://docs.fastlane.tools/actions/match/")
    end

    def profile_exists(profile_type: nil, name: nil, username: nil, uuid: nil, cached_profiles: nil)
      profiles = cached_profiles
      profiles ||= Match::Portal::Fetcher.profiles(profile_type: profile_type, name: name)

      found = profiles.find do |profile|
        profile.uuid == uuid
      end

      unless found
        UI.error("Provisioning profile '#{uuid}' is not available on the Developer Portal for the user #{username}, fixing this now for you 🔨")
        return false
      end

      if found.valid?
        return found
      else
        UI.important("'#{found.name}' is available on the Developer Portal, however it's 'Invalid', fixing this now for you 🔨")
        # it's easier to just create a new one, than to repair an existing profile
        # it has the same effects anyway, including a new UUID of the provisioning profile
        found.delete!
        # return nil to re-download the new profile in runner.rb
        return nil
      end
    end
  end
end
