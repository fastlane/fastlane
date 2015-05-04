require 'spec_helper'

describe Spaceship::Certificates do
  let(:client) { Spaceship::Client.instance }
  before { Spaceship::Client.login }

  describe "successfully loads and parses all certificates" do
    it "the number is correct" do
      expect(subject.count).to eq(3)
    end

    it "parses code signing identities correctly" do
      cert = subject.first

      expect(cert.id).to eq('XC5PH8DAAA')
      expect(cert.name).to eq('SunApps GmbH')
      expect(cert.status).to eq('Issued')
      expect(cert.created.to_s).to eq('2014-11-25T22:55:50Z')
      expect(cert.expires.to_s).to eq('2015-11-25T22:45:50Z')
      expect(cert.owner_type).to eq('team')
      expect(cert.owner_name).to eq('SunApps GmbH')
      expect(cert.owner_id).to eq('5A997XSAAA')
      expect(cert.is_push).to eq(false)
    end

    it "parses push certificates correctly" do
      push = subject['32KPRBAAAA'] # that's the push certificate

      expect(push.id).to eq('32KPRBAAAA')
      expect(push.name).to eq('net.sunapps.54')
      expect(push.status).to eq('Issued')
      expect(push.created.to_s).to eq('2015-04-02T21:34:00Z')
      expect(push.expires.to_s).to eq('2016-04-01T21:24:00Z')
      expect(push.owner_type).to eq('bundle')
      expect(push.owner_name).to eq('Timelack')
      expect(push.owner_id).to eq('3599RCHAAA')
      expect(push.is_push).to eq(true)
    end
  end

  it "Correctly filters the listed certificates" do
    certs = Spaceship::Certificates.new([Spaceship::Client::ProfileTypes::SigningCertificate.development])
    expect(certs.count).to eq(1)

    cert = certs.first
    expect(cert.id).to eq('C8DL7464RQ')
    expect(cert.name).to eq('Felix Krause')
    expect(cert.status).to eq('Issued')
    expect(cert.created.to_s).to eq('2014-11-25T22:55:50Z')
    expect(cert.expires.to_s).to eq('2015-11-25T22:45:50Z')
    expect(cert.owner_type).to eq('teamMember')
    expect(cert.owner_name).to eq('Felix Krause')
    expect(cert.owner_id).to eq('5Y354CXU3A')
    expect(cert.is_push).to eq(false)
  end

  describe '#file' do
    let(:cert) { subject.first }
    it 'downloads the associated .cer file' do
      x509 = OpenSSL::X509::Certificate.new(subject.file(cert.id))
      expect(x509.issuer.to_s).to match('Apple Worldwide Developer Relations')
    end
  end

  describe '#revoke' do
    let(:cert) { subject.first }
    it 'revokes certificate by the given cert id' do
      expect(client).to receive(:revoke_certificate).with('XC5PH8DAAA', 'R58UK2EAAA')
      subject.revoke(cert.id)
    end
  end

  describe '#create' do
    it 'should create and return a new certificate' do
      expect(client).to receive(:create_certificate).with('3BQKVH9I2X', /BEGIN CERTIFICATE REQUEST/, 'B7JBD8LHAA') {
        JSON.parse(read_fixture_file('certificateCreate.certRequest.json'))
      }
      certificate = nil

      expect {
        certificate = subject.create(Spaceship::Certificates::ProductionPush, 'net.sunapps.151')
      }.to change(subject, :count).by(+1)

      expect(certificate).to be_instance_of(Spaceship::Certificates::ProductionPush)
    end
  end
end
