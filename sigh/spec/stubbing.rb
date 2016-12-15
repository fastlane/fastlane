def sigh_stub_spaceship
  profile = "profile"
  certificate = "certificate"

  expect(Spaceship).to receive(:login).and_return(nil)
  allow(Spaceship).to receive(:client).and_return("client")
  expect(Spaceship).to receive(:select_team).and_return(nil)
  expect(Spaceship.client).to receive(:in_house?).and_return(false)

  allow(profile).to receive(:valid?).and_return(true)
  allow(profile.class).to receive(:pretty_type).and_return("pretty")
  allow(profile).to receive(:download).and_return("FileContent")
  allow(profile).to receive(:is_adhoc?).and_return(false)

  types = [Spaceship.provisioning_profile, Spaceship.provisioning_profile.app_store]
  types.each do |current|
    allow(current).to receive(:find_by_bundle_id).and_return([profile])
    allow(current).to receive(:all).and_return([profile])
  end

  certs = [Spaceship.certificate.production]
  certs.each do |current|
    allow(current).to receive(:all).and_return([certificate])
  end
end

def stub_request_valid_identities(resign, value)
  expect(resign).to receive(:request_valid_identities).and_return(value)
end
