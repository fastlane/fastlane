def pem_stub_spaceship
  expect(Spaceship).to receive(:login).and_return(nil)
  allow(Spaceship).to receive(:client).and_return("client")
  expect(Spaceship.client).to receive(:select_team).and_return(nil)
  expect(Spaceship.certificate).to receive(:all).and_return([])

  csr = "csr"
  pkey = "pkey"

  expect(Spaceship.certificate).to receive(:create_certificate_signing_request).and_return([csr, pkey])
  expect(pkey).to receive(:to_pem).twice.and_return("to_pem")
end

def pem_stub_spaceship_cert(platform: 'ios')
  csr = "csr"
  cert = "cert"
  x509 = "x509"

  case platform
  when 'macos'
    expect(Spaceship.certificate.mac_production_push).to receive(:create!).with(csr: csr, bundle_id: "com.krausefx.app").and_return(cert)
  else
    expect(Spaceship.certificate.production_push).to receive(:create!).with(csr: csr, bundle_id: "com.krausefx.app").and_return(cert)
  end

  expect(cert).to receive(:download).and_return(x509)
  expect(x509).to receive(:to_pem).and_return("to_pem")
end
