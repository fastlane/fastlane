
describe Match do
  describe Match::Runner do
    describe "select_cert selects best certificate" do
      class CertMock
        attr_accessor :not_before, :not_after, :serial
        def initialize(starts:, expires:, serial: )
          self.not_before = starts
          self.not_after = expires
          self.serial = serial
        end
      end

      let(:cert_a_path) { "a" }
      let(:cert_b_path) { "b" }
      let(:cert_c_path) { "c" }

      let(:cert_paths) { [cert_a_path, cert_b_path, cert_c_path].shuffle }

      before do
        cert_paths.each do |cert_path|
          # Mock File.binread
          allow(File).to receive(:binread).with(cert_path).and_return(cert_path)
          # Mock basename
          allow(File).to receive(:basename).with(cert_path).and_return(cert_path)
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
        selected_cert = Match::Runner.select_cert(cert_paths: cert_paths)

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
        selected_cert = Match::Runner.select_cert(cert_paths: cert_paths)

        # THEN
        expect(selected_cert).to eq(cert_b_path)
      end

      it "selects cert with specified cert_id ()" do
        # GIVEN
        cert_id = 'a'

        # WHEN
        selected_cert = Match::Runner.select_cert(cert_paths: cert_paths, cert_id: cert_id)

        # THEN
        expect(selected_cert).to eq(cert_a_path)
      end
    end
  end
end
