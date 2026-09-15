describe Spaceship::ConnectAPI::BuildUpload do
  include_examples "common spaceship login"

  describe '#Spaceship::ConnectAPI' do
    it '#get_build_uploads' do
      expected_state = { "errors" => [], "infos" => [], "state" => "COMPLETE", "warnings" => [] }

      response = Spaceship::ConnectAPI.get_build_uploads(app_id: "1234")
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(1)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::BuildUpload)
      end

      model = response.first
      expect(model.id).to eq("123456789")
      expect(model.cf_build_version).to eq("45")
      expect(model.cf_build_short_version_string).to eq("1.2.3")
      expect(model.created_date).to eq("2026-01-25T23:07:08-08:00")
      expect(model.state).to eq(expected_state)
      expect(model.state["state"]).to eq("COMPLETE")
      expect(model.platform).to eq("IOS")
      expect(model.uploaded_date).to eq("2026-01-25T23:08:09-08:00")
    end
  end
end
