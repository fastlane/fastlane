describe Spaceship::ConnectAPI::BuildBundleFileSizes do
  include_examples "common spaceship login"

  describe '#Spaceship::ConnectAPI' do
    it '#get_build_bundles_build_bundle_file_sizes' do
      response = Spaceship::ConnectAPI.get_build_bundles_build_bundle_file_sizes(build_bundle_id: '48a9bb1f-5f0f-4133-8c72-3fb93e92603a')
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(50)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::BuildBundleFileSizes)
      end

      model = response.first
      expect(model.id).to eq("82ee11de-a206-371c-8e4f-a79b9185c962")
      expect(model.device_model).to eq("Universal")
      expect(model.os_version).to eq("Universal")
      expect(model.download_bytes).to eq(54_844_802)
      expect(model.install_bytes).to eq(74_799_104)
    end
  end
end
