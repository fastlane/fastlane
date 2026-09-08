describe Spaceship::ConnectAPI::PassTypeId do
  include_examples "common spaceship login"

  describe '#client' do
    it '#get_pass_type_ids' do
      response = Spaceship::ConnectAPI.get_pass_type_ids
      expect(response).to be_an_instance_of(Spaceship::ConnectAPI::Response)

      expect(response.count).to eq(2)
      response.each do |model|
        expect(model).to be_an_instance_of(Spaceship::ConnectAPI::PassTypeId)
      end

      model = response.first
      expect(model.id).to eq("4B77K434AB")
      expect(model.identifier).to eq("pass.com.joshholtz.FastlaneApp")
      expect(model.name).to eq("Fastlane App Pass")
    end
  end

  describe '#all' do
    it 'returns all pass type ids' do
      pass_type_ids = Spaceship::ConnectAPI::PassTypeId.all
      expect(pass_type_ids.count).to eq(2)
      expect(pass_type_ids.map(&:identifier)).to eq(["pass.com.joshholtz.FastlaneApp", "pass.com.joshholtz.circle.Example"])
    end
  end

  describe '#find' do
    it 'finds a pass type id by its identifier' do
      pass_type_id = Spaceship::ConnectAPI::PassTypeId.find("pass.com.joshholtz.circle.Example")
      expect(pass_type_id).to be_an_instance_of(Spaceship::ConnectAPI::PassTypeId)
      expect(pass_type_id.id).to eq("5C88L545BC")
    end

    it 'returns nil when the pass type id does not exist' do
      pass_type_id = Spaceship::ConnectAPI::PassTypeId.find("pass.com.joshholtz.DoesNotExist")
      expect(pass_type_id).to be_nil
    end
  end
end
