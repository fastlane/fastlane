
describe Match do
  describe Match::Runner do
    describe "certs validity and sort" do
      let(:cert_a_path) { "a.cer" }
      let(:cert_b_path) { "b.cer" }
      let(:cert_c_path) { "c.cer" }

      let(:common_cert_paths) { [cert_a_path, cert_b_path, cert_c_path] }

      describe "#select_cert" do
        let(:cert_paths) { common_cert_paths.shuffle }

        before do
          cert_paths.each do |cert_path|
            # Mock File.binread
            allow(File).to receive(:binread).with(cert_path).and_return(cert_path)
            # Mock basename
            allow(File).to receive(:basename).with(cert_path).and_return(cert_path)
          end
        end

        class CertMock
          attr_accessor :not_before, :not_after, :serial
          def initialize(starts:, expires:, serial:)
            self.not_before = starts
            self.not_after = expires
            self.serial = serial
          end
        end

        def mock_certs(cert_a, cert_b, cert_c)
          allow(OpenSSL::X509::Certificate).to receive(:new).with(cert_a_path).and_return(cert_a)
          allow(OpenSSL::X509::Certificate).to receive(:new).with(cert_b_path).and_return(cert_b)
          allow(OpenSSL::X509::Certificate).to receive(:new).with(cert_c_path).and_return(cert_c)
        end

        it "selects newest certificate with the furthest expiration date (not_after)" do
          # GIVEN
          cert_a = CertMock.new(starts: Time.new(2018, 1, 1), expires: Time.new(2019, 1, 1), serial: 1)
          cert_b = CertMock.new(starts: Time.new(2024, 1, 1), expires: Time.new(2025, 1, 2), serial: 1)
          cert_c = CertMock.new(starts: Time.new(2024, 1, 1), expires: Time.new(2025, 1, 3), serial: 1)

          mock_certs(cert_a, cert_b, cert_c)

          # WHEN
          selected_cert = Match::Runner.new.select_cert(cert_paths: cert_paths)

          # THEN
          expect(selected_cert).to eq(cert_c_path)
        end

        it "selects newest certificate with the most recent creation date (not_before) if two have same expiration date" do
          # GIVEN
          cert_a = CertMock.new(starts: Time.new(2018, 1, 1), expires: Time.new(2019, 1, 1), serial: 1)
          cert_b = CertMock.new(starts: Time.new(2024, 1, 3), expires: Time.new(2025, 1, 2), serial: 1)
          cert_c = CertMock.new(starts: Time.new(2024, 1, 2), expires: Time.new(2025, 1, 2), serial: 1)

          mock_certs(cert_a, cert_b, cert_c)

          # WHEN
          selected_cert = Match::Runner.new.select_cert(cert_paths: cert_paths)

          # THEN
          expect(selected_cert).to eq(cert_b_path)
        end

        it "selects cert with specified cert_id ()" do
          # GIVEN
          cert_id = 'a'

          # WHEN
          selected_cert = Match::Runner.new.select_cert(cert_paths: cert_paths, cert_id: cert_id)

          # THEN
          expect(selected_cert).to eq(cert_a_path)
        end
      end

      describe "#remove_expired_certs" do
        let(:cert_paths) { common_cert_paths }

        before do
          cert_paths.each do |cert_path|
            # File existance
            allow(File).to receive(:exist?).with(cert_path).and_return(true)
            allow(File).to receive(:exist?).with(cert_path.gsub(/\.cer$/, ".p12")).and_return(true)
          end
        end

        def mock_certs_validity(is_cert_a_valid, is_cert_b_valid, is_cert_c_valid)
          allow(Match::Utils).to receive(:is_cert_valid?).with(cert_a_path).and_return(is_cert_a_valid)
          allow(Match::Utils).to receive(:is_cert_valid?).with(cert_b_path).and_return(is_cert_b_valid)
          allow(Match::Utils).to receive(:is_cert_valid?).with(cert_c_path).and_return(is_cert_c_valid)
        end

        it "removes certs from the list and the storage when not in readonly mode" do
          # GIVEN
          mock_certs_validity(true, false, true)

          # Expectations
          # Delete .cer and .p12 files
          private_key_b_path = cert_b_path.gsub(/\.cer/, ".p12")
          expect(File).to receive(:delete).with(cert_b_path).once
          expect(File).to receive(:delete).with(private_key_b_path).once

          # WHEN
          sut = Match::Runner.new
          sut.remove_expired_certs(cert_paths: cert_paths, readonly: false)

          # THEN
          expect(cert_paths).to eq([cert_a_path, cert_c_path])
          expect(sut.files_to_delete).to eq([cert_b_path, private_key_b_path])
        end

        it "removes certs only from the list when in readonly mode" do
          # GIVEN
          mock_certs_validity(false, false, false)

          # WHEN
          sut = Match::Runner.new
          sut.remove_expired_certs(cert_paths: cert_paths, readonly: true)

          # THEN
          expect(cert_paths).to eq([])
          expect(sut.files_to_delete).to eq([])
        end
      end
    end
  end
end
