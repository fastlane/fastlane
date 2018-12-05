def sigh_stub_spaceship(valid_profile = true, expect_create = false, expect_delete = false)
  profile = "profile"
  certificate = "certificate"

  expect(Spaceship).to receive(:login).and_return(nil)
  allow(Spaceship).to receive(:client).and_return("client")
  expect(Spaceship).to receive(:select_team).and_return(nil)
  expect(Spaceship.client).to receive(:in_house?).and_return(false)
  allow(Spaceship.app).to receive(:find).and_return(true)
  allow(Spaceship.provisioning_profile).to receive(:all).and_return([])

  allow(profile).to receive(:valid?).and_return(valid_profile)
  allow(profile.class).to receive(:pretty_type).and_return("pretty")
  allow(profile).to receive(:download).and_return("FileContent")
  allow(profile).to receive(:is_adhoc?).and_return(false)
  allow(profile).to receive(:name).and_return("profile name")
  if expect_delete
    expect(profile).to receive(:delete!)
  else
    expect(profile).to_not(receive(:delete!))
  end

  profile_type = Spaceship.provisioning_profile.app_store
  allow(profile_type).to receive(:find_by_bundle_id).and_return([profile])
  allow(profile_type).to receive(:all).and_return([profile])
  if expect_create
    expect(profile_type).to receive(:create!).and_return(profile)
  else
    expect(profile_type).to_not(receive(:create!))
  end

  certs = [Spaceship.certificate.production]
  certs.each do |current|
    allow(current).to receive(:all).and_return([certificate])
  end
end

def stub_request_valid_identities(resign, value)
  expect(resign).to receive(:request_valid_identities).and_return(value)
end
