require 'spec_helper'

describe PEM::CertManager do
  before do
    subject.rsa_file = fixture_path('localhost.key')
    subject.cert_file = fixture_path('localhost.cer')
  end
  context '#private_key' do
    it { expect(subject.private_key).to respond_to(:to_pem) }
  end
  context '#x509_certificate' do
    it { expect(subject.x509_certificate).to respond_to(:to_pem) }
  end
  context '#p12_certificate' do
    it { expect(subject.p12_certificate).to respond_to(:to_der) }
  end
end
