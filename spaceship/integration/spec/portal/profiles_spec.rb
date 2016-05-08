describe Spaceship do
  describe Spaceship::Portal do
    describe Spaceship::Portal::Certificate do
      describe "Create a new iOS Development Profile" do
        it "creates an active profile and delete it" do
          cert = Spaceship::Certificate::Development.all.first
          bundle_id = Spaceship::App.all.first.bundle_id
          profile = Spaceship::ProvisioningProfile::Development.create!(name: 'Delete Me iOS', bundle_id: bundle_id, certificate: cert, devices: nil, mac: false)
          expect(profile.nil? == false)
          expect(profile.status.equal?("Active"))

          # We need to delete these as the dev portal will not let you create a profile with the same name and I'm not
          # sure if there is a limit to the number of profiles that you can have.
          result = profile.delete!
          expect(result[:resultCode].equal?(0))
        end
      end

      describe "Create a new tvOS Development Profile" do
        it "creates an active profile and delete it" do
          cert = Spaceship::Certificate::Development.all.first
          bundle_id = Spaceship::App.all.first.bundle_id
          profile = Spaceship::ProvisioningProfile::Development.create!(name: 'Delete Me tvOS', bundle_id: bundle_id, certificate: cert, devices: nil, mac: false, sub_platform: "tvOS")
          expect(profile.nil? == false)
          expect(profile.status.equal?("Active"))
          expect(profile.platform.equal?("tvos"))

          # We need to delete these as the dev portal will not let you create a profile with the same name and I'm not
          # sure if there is a limit to the number of profiles that you can have.
          result = profile.delete!
          expect(result[:resultCode].equal?(0))
        end
      end
    end
  end
end
