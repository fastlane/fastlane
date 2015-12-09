module Match
  # Ensures the certificate and profiles are also available on iTunes Connect
  class SpaceshipEnsure
    def initialize(user)
      Spaceship.login(user)
      Spaceship.select_team
    end

    def certificate_exists?(certificate_id)
      Spaceship.certificate.all.find do |cert|
        cert.id == certificate_id
      end
    end

    def profile_exists?(uuid)
      Spaceship.provisioning_profile.all.find do |profile|
        profile.uuid == uuid
      end
    end
  end
end
