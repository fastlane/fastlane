describe Spaceship do
  describe Spaceship::Portal do
    describe Spaceship::Portal::Certificate do
      let(:certificate) { Spaceship::Portal.certificate }

      before(:all) do
        @certificates = Spaceship::Portal.certificate.all
      end

      it 'finds certificates on the portal' do
        expect(@certificates).to_not be_empty
      end

      it 'fetched certificates have reasonable data' do
        cert = @certificates.first

        expect(cert.id).to match_apple_ten_char_id
        expect(cert.name).to_not be_empty
        expect(cert.status).to eq('Issued')
        expect(cert.created).to be_kind_of(Time)
        expect(cert.expires).to be_kind_of(Time)
        expect(cert.owner_id).to match_apple_ten_char_id
        expect(cert.type_display_id).to match_apple_ten_char_id
        expect(cert.can_download).to be(true)
      end

      it 'certificate creation and revokation work' do
        begin
          # Create a new certificate signing request
          csr, = certificate.create_certificate_signing_request

          # Use the signing request to create a new distribution certificate
          created_cert = certificate.production.create!(csr: csr)
          created_cert_id = created_cert.id

          expect(created_cert_id).to match_apple_ten_char_id
          expect(created_cert.status).to eq("Issued")

          # re-fetch certificates to see if this one we just made is present
          expect(certificate.all.any? { |cert| cert.id == created_cert_id }).to be(true)
        ensure
          # Do this in an ensure block to ensure that the cert is cleaned up even if an error occurs
          if created_cert
            created_cert.revoke!

            # re-fetch certificates to see if this one we just made has been revoked
            expect(certificate.all.any? { |cert| cert.id == created_cert_id }).to be(false)
          end
        end
      end

      it 'downloads and returns an actual Certificate object' do
        x509_cert = @certificates.first.download

        expect(x509_cert).to be_kind_of(OpenSSL::X509::Certificate)
        expect(x509_cert.issuer.to_s).to match(/Apple Inc\./)
      end
    end
  end
end
