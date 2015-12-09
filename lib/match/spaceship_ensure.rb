module Match
  # Ensures the certificate and profiles are also available on iTunes Connect
  class SpaceshipEnsure
    def initialize(user)
      Spaceship.login(user)
      Spaceship.select_team
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
      UI.user_error!("To reset the certificates of your Apple account, you can use the `match nuke` feature, more information on https://github.com/fastlane/match")
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
      UI.user_error!("To reset the provisioning profiles of your Apple account, you can use the `match nuke` feature, more information on https://github.com/fastlane/match")
    end
  end
end
