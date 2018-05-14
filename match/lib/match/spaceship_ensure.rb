require 'spaceship'
require_relative 'module'

module Match
  # Ensures the certificate and profiles are also available on iTunes Connect
  class SpaceshipEnsure
    def initialize(user, team_id, team_name)
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

      UI.message("Verifying that the certificate and profile are still valid on the Dev Portal...")
      Spaceship.login(user)
      Spaceship.select_team(team_id: team_id, team_name: team_name)
    end

    def bundle_identifier_exists(username: nil, app_identifier: nil)
      found = Spaceship.app.find(app_identifier)
      return if found

      require 'sigh/runner'
      Sigh::Runner.new.print_produce_command({
        username: username,
        app_identifier: app_identifier
      })
      UI.error("An app with that bundle ID needs to exist in order to create a provisioning profile for it")
      UI.error("================================================================")
      available_apps = Spaceship.app.all.collect { |a| "#{a.bundle_id} (#{a.name})" }
      UI.message("Available apps:\n- #{available_apps.join("\n- ")}")
      UI.error("Make sure to run `fastlane match` with the same user and team every time.")
      UI.user_error!("Couldn't find bundle identifier '#{app_identifier}' for the user '#{username}'")
    end

    def certificate_exists(username: nil, certificate_id: nil)
      found = Spaceship.certificate.all.find do |cert|
        cert.id == certificate_id
      end
      return if found

      UI.error("Certificate '#{certificate_id}' (stored in your git repo) is not available on the Developer Portal")
      UI.error("for the user #{username}")
      UI.error("Make sure to use the same user and team every time you run 'match' for this")
      UI.error("Git repository. This might be caused by revoking the certificate on the Dev Portal")
      UI.user_error!("To reset the certificates of your Apple account, you can use the `fastlane match nuke` feature, more information on https://docs.fastlane.tools/actions/match/")
    end

    def profile_exists(username: nil, uuid: nil)
      found = Spaceship.provisioning_profile.all.find do |profile|
        profile.uuid == uuid
      end

      unless found
        UI.error("Provisioning profile '#{uuid}' is not available on the Developer Portal")
        UI.error("for the user #{username}")
        UI.error("Make sure to use the same user and team every time you run 'match' for this")
        UI.error("Git repository. This might be caused by deleting the provisioning profile on the Dev Portal")
        UI.user_error!("To reset the provisioning profiles of your Apple account, you can use the `fastlane match nuke` feature, more information on https://docs.fastlane.tools/actions/match/")
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
