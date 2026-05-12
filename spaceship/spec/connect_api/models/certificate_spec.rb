describe Spaceship::ConnectAPI::Certificate do
  include_examples "common spaceship login"

  describe '#client' do
    it '#get_certificates' do
      response = Spaceship::ConnectAPI.get_certificates
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(5)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::Certificate)
      end

      model = response.first
      expect(model.id).to eq("123456789")
      expect(model.certificate_content).to eq("content")
      expect(model.display_name).to eq("Josh Holtz")
      expect(model.name).to eq("iOS Development: Josh Holtz")
      expect(model.platform).to eq("IOS")
      expect(model.serial_number).to eq("F5A44933E05F97D")
      expect(model.certificate_type).to eq("IOS_DEVELOPMENT")
      expect(model.requester_email).to eq("email@email.com")
      expect(model.requester_first_name).to eq("Josh")
      expect(model.requester_last_name).to eq("Holtz")
    end

    let!(:default_parameters) do
      {
          fields: nil,
          filter: nil,
          includes: nil,
          limit: Spaceship::ConnectAPI::MAX_OBJECTS_PER_PAGE_LIMIT,
          sort: nil
      }
    end

    it '#get_certificates with unsupported certificate types' do
      certificate_type = Spaceship::ConnectAPI::Certificate::CertificateType::DEVELOPER_ID_APPLICATION_G2

      # Will fetch all certificates w/o filtering by certificate type
      parameters = default_parameters.merge(filter: {})
      allow(Spaceship::ConnectAPI).to receive(:get_certificates).with(parameters).and_call_original

      response = Spaceship::ConnectAPI::Certificate.all(filter: { certificateType: [certificate_type] })
      # But will filter by certificate in the response
      expect(response.count).to eq(1)

      model = response.first
      expect(model.id).to eq("777888999")
      expect(model.certificate_content).to eq("content")
      expect(model.display_name).to eq("Josh Holtz")
      expect(model.name).to eq("Developer ID Application (G2): Josh Holtz")
      expect(model.platform).to eq("MAC_OS_X")
      expect(model.serial_number).to eq("6FF0AA8635503A3D")
      expect(model.certificate_type).to eq("DEVELOPER_ID_APPLICATION_G2")
      expect(model.requester_email).to eq("email@email.com")
      expect(model.requester_first_name).to eq("Josh")
    end

    it '#get_certificates with a supported certificate type' do
      certificate_type = Spaceship::ConnectAPI::Certificate::CertificateType::IOS_DISTRIBUTION

      # Will pass filter to Spaceship::ConnectAPI
      parameters = default_parameters.merge(filter: { certificateType: [certificate_type] })
      allow(Spaceship::ConnectAPI).to receive(:get_certificates).with(parameters).and_call_original

      response = Spaceship::ConnectAPI::Certificate.all(filter: { certificateType: [certificate_type] })

      # Spaceship::ConnectAPI is stubbed, thus filter is ignored and all certificates are returned
      expect(response.count).to eq(5)
    end
  end

  describe '#valid?' do
    let!(:certificate) do
      certificates_response = JSON.parse(File.read(File.join('spaceship', 'spec', 'connect_api', 'fixtures', 'provisioning', 'certificates.json')))
      model = Spaceship::ConnectAPI::Models.parse(certificates_response).first
    end

    context 'with past expiration_date' do
      before { certificate.expiration_date = "1999-02-01T20:50:34.000+0000" }

      it 'should be invalid' do
        expect(certificate.valid?).to eq(false)
      end
    end

    context 'with a future expiration_date' do
      before { certificate.expiration_date = "9999-02-01T20:50:34.000+0000" }

      it 'should be valid' do
        expect(certificate.valid?).to eq(true)
      end
    end

    context 'when expiration_date is nil' do
      before { certificate.expiration_date = nil }

      it 'should be invalid' do
        expect(certificate.valid?).to eq(false)
      end
    end

    context 'when expiration_date is an empty string' do
      before { certificate.expiration_date = "" }

      it 'should be invalid' do
        expect(certificate.valid?).to eq(false)
      end
    end
  end
end
