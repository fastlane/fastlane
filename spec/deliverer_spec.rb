describe Deliver do
  describe Deliver::Deliverer do
    describe "#initialize with hash" do
      it "raises an exception when some information is missing" do
        expect {
          @meta = Deliver::Deliverer.new(nil, hash: {})
        }.to raise_exception("No App Version given")
      end

      it "raises exception if not beta_ipa is given in beta build" do
        version = '1.0'
        identifier = 'at.felixkrause.iTanky'
        ipa = "spec/fixtures/ipas/Example1.ipa"

        expect {
          @meta = Deliver::Deliverer.new(nil, hash: {
            app_identifier: identifier,
            version: version,
            ipa: ipa,
          }, is_beta_ipa: true, skip_deploy: true)
        }.to raise_exception "Could not find an ipa file for 'beta' mode. Provide one using `beta_ipa do ... end` in your Deliverfile.".red
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
          ipa: ipa,
        }, is_beta_ipa: false, skip_deploy: true,)

        expect(@meta.deliver_process.deploy_information[:version]).to eq(version)
        expect(@meta.deliver_process.deploy_information[:app_identifier]).to eq(identifier)
        expect(@meta.deliver_process.deploy_information[:ipa]).to eq(ipa)
        expect(@meta.deliver_process.deploy_information[:is_beta_ipa]).to eq(false)
        expect(@meta.deliver_process.deploy_information[:skip_deploy]).to be_truthy
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
        expect(del.deliver_process.deploy_information[:version]).to eq("2.0")
      end
    end
  end
end
