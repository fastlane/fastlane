module Match
  # Ensures the certificate and profiles are also available on iTunes Connect
  class SpaceshipEnsure
    def self.certificate_exists?(certificate_id)
      Spaceship.login
      Spaceship.select_team
      Spaceship.certificate.all.each do |cert|
        return cert if cert.id == certificate_id
      end
      nil
    end
  end
end
