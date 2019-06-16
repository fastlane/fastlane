def pem_stub_spaceship
  expect(Spaceship).to receive(:login).and_return(nil)
  allow(Spaceship).to receive(:client).and_return("client")
  expect(Spaceship.client).to receive(:select_team).and_return(nil)
  expect(Spaceship.certificate).to receive(:all).and_return([])

  csr = "csr"
  pkey = "pkey"
  cert = "cert"
  x509 = "x509"

  expect(Spaceship.certificate).to receive(:create_certificate_signing_request).and_return([csr, pkey])
  expect(Spaceship.certificate.production_push).to receive(:create!).with(csr: csr, bundle_id: "com.krausefx.app").and_return(cert)
  expect(cert).to receive(:download).and_return(x509)
  expect(pkey).to receive(:to_pem).twice.and_return("to_pem")
  expect(x509).to receive(:to_pem).and_return("to_pem")
end
