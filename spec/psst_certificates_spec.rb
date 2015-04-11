require 'spec_helper'

describe Spaceship do
  describe "Certificate" do
    before do
      @client = Spaceship::Client.new
    end

    describe "successfully loads and parses all certificates" do
      before do
        @certs = @client.certificates # no parameter => all profiles
      end

      it "the number is correct" do
        expect(@certs.count).to eq(3)
      end

      it "parses code signing identities correctly" do
        cert = @certs.first

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
        push = @certs[1] # that's the push certificate

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
      certs = @client.certificates(Spaceship::Client::ProfileTypes::SigningCertificate.development)
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
  end
end