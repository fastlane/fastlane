def stub_spaceship
  certificate = "certificate"

  expect(Spaceship).to receive(:login).and_return(nil)
  allow(Spaceship).to receive(:client).and_return("client")
  expect(Spaceship).to receive(:select_team).and_return(nil)
  expect(Spaceship.client).to receive(:in_house?).and_return(false)

  expect(Spaceship.certificate.production).to receive(:all).and_return([certificate])

  allow(certificate).to receive(:id).and_return("cert_id")
  allow(certificate).to receive(:download_raw).and_return("download_raw")
  allow(certificate).to receive(:name).and_return("name")
  allow(certificate).to receive(:can_download).and_return(true)

  allow(FastlaneCore::CertChecker).to receive(:installed?).and_return(true)
end
