describe Spaceship::Certificate do
  before { Spaceship.login }
  let(:client) { Spaceship::Portal::Certificate.client }

  describe "successfully loads and parses all certificates" do
    it "the number is correct" do
      expect(Spaceship::Portal::Certificate.all.count).to eq(3)
    end

    it "inspect works" do
      expect(Spaceship::Portal::Certificate.all.first.inspect).to include("Portal::Certificate")
    end

    it "parses code signing identities correctly" do
      cert = Spaceship::Portal::Certificate.all.first

      expect(cert.id).to eq('XC5PH8DAAA')
      expect(cert.name).to eq('SunApps GmbH')
      expect(cert.status).to eq('Issued')
      expect(cert.created.class).to eq(Time)
      expect(cert.expires.class).to eq(Time)
      expect(cert.created.to_s).to eq('2014-11-25 22:55:50 UTC')
      expect(cert.expires.to_s).to eq('2015-11-25 22:45:50 UTC')
      expect(cert.owner_type).to eq('team')
      expect(cert.owner_name).to eq('SunApps GmbH')
      expect(cert.owner_id).to eq('5A997XSAAA')
      expect(cert.is_push?).to eq(false)
    end

    it "parses push certificates correctly" do
      push = Spaceship::Portal::Certificate.find('32KPRBAAAA') # that's the push certificate

      expect(push.id).to eq('32KPRBAAAA')
      expect(push.name).to eq('net.sunapps.54')
      expect(push.status).to eq('Issued')
      expect(push.created.to_s).to eq('2015-04-02 21:34:00 UTC')
      expect(push.expires.to_s).to eq('2016-04-01 21:24:00 UTC')
      expect(push.owner_type).to eq('bundle')
      expect(push.owner_name).to eq('Timelack')
      expect(push.owner_id).to eq('3599RCHAAA')
      expect(push.is_push?).to eq(true)
    end
  end

  it "Correctly filters the listed certificates" do
    certs = Spaceship::Portal::Certificate::Development.all
    expect(certs.count).to eq(1)

    cert = certs.first
    expect(cert.id).to eq('C8DL7464RQ')
    expect(cert.name).to eq('Felix Krause')
    expect(cert.status).to eq('Issued')
    expect(cert.created.to_s).to eq('2014-11-25 22:55:50 UTC')
    expect(cert.expires.to_s).to eq('2015-11-25 22:45:50 UTC')
    expect(cert.owner_type).to eq('teamMember')
    expect(cert.owner_name).to eq('Felix Krause')
    expect(cert.owner_id).to eq('5Y354CXU3A')
    expect(cert.is_push?).to eq(false)
  end

  describe '#download' do
    let(:cert) { Spaceship::Portal::Certificate.all.first }
    it 'downloads the associated .cer file' do
      x509 = OpenSSL::X509::Certificate.new(cert.download)
      expect(x509.issuer.to_s).to match('Apple Worldwide Developer Relations')
    end

    it "handles failed download request" do
      PortalStubbing.adp_stub_download_certificate_failure

      error_text = /^Couldn't download certificate, got this instead:/
      expect do
        cert.download
      end.to raise_error(Spaceship::Client::UnexpectedResponse, error_text)
    end
  end

  describe '#revoke' do
    let(:cert) { Spaceship::Portal::Certificate.all.first }
    it 'revokes certificate by the given cert id' do
      expect(client).to receive(:revoke_certificate!).with('XC5PH8DAAA', 'R58UK2EAAA', mac: false)
      cert.revoke!
    end
  end

  describe '#create' do
    it 'should create and return a new certificate' do
      expect(client).to receive(:create_certificate!).with('UPV3DW712I', /BEGIN CERTIFICATE REQUEST/, 'B7JBD8LHAA', false) {
        JSON.parse(PortalStubbing.adp_read_fixture_file('certificateCreate.certRequest.json'))
      }
      csr, pkey = Spaceship::Portal::Certificate.create_certificate_signing_request
      certificate = Spaceship::Portal::Certificate::ProductionPush.create!(csr: csr, bundle_id: 'net.sunapps.151')
      expect(certificate).to be_instance_of(Spaceship::Portal::Certificate::ProductionPush)
    end

    it 'should create a new certificate using a CSR from a file' do
      expect(client).to receive(:create_certificate!).with('UPV3DW712I', /BEGIN CERTIFICATE REQUEST/, 'B7JBD8LHAA', false) {
        JSON.parse(PortalStubbing.adp_read_fixture_file('certificateCreate.certRequest.json'))
      }
      csr, pkey = Spaceship::Portal::Certificate.create_certificate_signing_request
      Tempfile.open('csr') do |f|
        f.write(csr.to_pem)
        f.rewind
        pem = f.read
        Spaceship::Portal::Certificate::ProductionPush.create!(csr: pem, bundle_id: 'net.sunapps.151')
      end
    end

    it 'raises an error if the user wants to create a certificate for a non-existing app' do
      expect do
        csr, pkey = Spaceship::Portal::Certificate.create_certificate_signing_request
        Spaceship::Portal::Certificate::ProductionPush.create!(csr: csr, bundle_id: 'notExisting')
      end.to raise_error("Could not find app with bundle id 'notExisting'")
    end
  end
end
