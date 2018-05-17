require 'spec_helper'
class B2bUserSpec
  describe Spaceship::Tunes::B2bUser do
    before { Spaceship::Tunes.login }
    before { TunesStubbing.itc_stub_app_pricing_intervals }

    let(:client) { Spaceship::AppVersion.client }
    let(:app) { Spaceship::Application.all.first }
    let(:mock_client) { double('MockClient') }
    let(:b2b_user) do
      Spaceship::Tunes::B2bUser.new(
        'value' => {
            'dsUsername' => "b2b1@abc.com",
            'delete' => false,
            'add' => false,
            'company' => 'b2b1'
        },
        "isEditable" => true,
        "isRequired" => false
      )
    end
    before do
      allow(Spaceship::Tunes::TunesBase).to receive(:client).and_return(mock_client)
      allow(mock_client).to receive(:team_id).and_return('')
    end

    describe 'b2b_user' do
      it 'parses the data correctly' do
        expect(b2b_user).to be_instance_of(Spaceship::Tunes::B2bUser)
        !expect(b2b_user.add)
        !expect(b2b_user.delete)
        expect(b2b_user.ds_username).to eq('b2b1@abc.com')
      end
    end

    describe 'from_username' do
      it 'creates correct object to add' do
        b2b_user_created = Spaceship::Tunes::B2bUser.from_username("b2b2@def.com")
        expect(b2b_user_created.add)
        !expect(b2b_user_created.delete)
        expect(b2b_user_created.ds_username).to eq('b2b2@def.com')
      end
    end
  end
end
