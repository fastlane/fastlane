module Match
  # Ensures the certificate and profiles are also available on iTunes Connect
  class SpaceshipEnsure
    def initialize(user)
      # We'll try to manually fetch the password
      # to tell the user that a password is optional
      require 'credentials_manager'

      keychain_entry = CredentialsManager::AccountManager.new(user: user)

      if keychain_entry.password(ask_if_missing: false).to_s.length == 0
        UI.important("You can also run `match` in readonly mode to not require any access to the")
        UI.important("Developer Portal. This way you only share the keys and credentials")
        UI.command("match --readonly")
        UI.important("More information https://github.com/fastlane/fastlane/tree/master/match#access-control")
      end

      UI.message("Verifying that the certificate and profile are still valid on the Dev Portal...")
      Spaceship.login(user)
      Spaceship.select_team
    end

    def bundle_identifier_exists(params)
      found = Spaceship.app.find(params[:app_identifier])
      return if found

      require 'sigh'
      Sigh::Runner.new.print_produce_command({
        username: params[:username],
        app_identifier: params[:app_identifier]
      })
      UI.error("An app with that bundle ID needs to exist in order to create a provisioning profile for it")
      UI.error("================================================================")
      UI.error("Make sure to run `match` with the same user and team every time.")
      UI.user_error!("Couldn't find bundle identifier '#{params[:app_identifier]}' for the user '#{params[:username]}'")
    end

    def certificate_exists(params, certificate_id)
      found = Spaceship.certificate.all.find do |cert|
        cert.id == certificate_id
      end
      return if found

      UI.error("Certificate '#{certificate_id}' (stored in your git repo) is not available on the Developer Portal")
      UI.error("for the user #{params[:username]}")
      UI.error("Make sure to use the same user and team every time you run 'match' for this")
      UI.error("Git repository. This might be caused by revoking the certificate on the Dev Portal")
      UI.user_error!("To reset the certificates of your Apple account, you can use the `match nuke` feature, more information on https://github.com/fastlane/fastlane/tree/master/match")
    end

    def profile_exists(params, uuid)
      found = Spaceship.provisioning_profile.all.find do |profile|
        profile.uuid == uuid
      end
      return if found

      UI.error("Provisioning profile '#{uuid}' is not available on the Developer Portal")
      UI.error("for the user #{params[:username]}")
      UI.error("Make sure to use the same user and team every time you run 'match' for this")
      UI.error("Git repository. This might be caused by deleting the provisioning profile on the Dev Portal")
      UI.user_error!("To reset the provisioning profiles of your Apple account, you can use the `match nuke` feature, more information on https://github.com/fastlane/fastlane/tree/master/match")
    end
  end
end
