describe Deliver do
  describe Deliver::Deliverer do
    describe "#initialize with hash" do
      it "raises an exception when some information is missing" do
        expect {
          @meta = Deliver::Deliverer.new(nil, hash: {})
        }.to raise_exception("You have to pass a valid app identifier using the Deliver file. (e.g. 'app_identifier \"net.sunapps.app\"')".red)
      end

      it "works with valid data" do
        Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/download_valid_apple_id.txt")
        Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt") # metadata
        Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt") # ipa file

        version = '1.0'
        identifier = 'at.felixkrause.iTanky'
        ipa = "spec/fixtures/ipas/Example1.ipa"

        @meta = Deliver::Deliverer.new(nil, hash: {
          app_identifier: identifier,
          version: version,
          ipa: ipa
        })

        expect(@meta.deploy_information[:version]).to eq(version)
        expect(@meta.deploy_information[:app_identifier]).to eq(identifier)
        expect(@meta.deploy_information[:ipa]).to eq(ipa)
      end
    end

    describe "#set_new_value" do
      it "raises an exception when invalid key is used" do
        expect {
          Deliver::Deliverer.new(nil, hash: { app_identifier: 'net.sunapps.54', invalid_key: '1' })
        }.to raise_error("Invalid key 'invalid_key', must be contained in Deliverer::ValKey.".red)
      end

      it "works when the same value is set twice" do
        Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/download_valid_apple_id.txt")
        Deliver::ItunesTransporter.set_mock_file("spec/responses/transporter/upload_valid.txt")

        del = Deliver::Deliverer.new(nil, hash: { app_identifier: 'net.sunapps.54', version: '1.0', apple_id: 878567776 })
        del.set_new_value(:version, '2.0')
        expect(del.deploy_information[:version]).to eq("2.0")
      end
    end
  end
end