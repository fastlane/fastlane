require 'spec_helper'
# require_relative '../../../spaceship/lib/spaceship/tunes/b2b_organization'
class B2bOrganizationSpec
  describe Spaceship::Tunes::B2bOrganization do
    before { Spaceship::Tunes.login }
    before { TunesStubbing.itc_stub_app_pricing_intervals }

    let(:client) { Spaceship::AppVersion.client }
    let(:app) { Spaceship::Application.all.first }
    let(:mock_client) { double('MockClient') }
    let(:b2b_organization) do
      Spaceship::Tunes::B2bOrganization.new(
        'value' => {
            'type' => "DELETE",
            'depCustomerId' => 'abcdefgh',
            'organizationId' => '1234567890',
            'name' => 'My awesome company'
        }
      )
    end
    before do
      allow(Spaceship::Tunes::TunesBase).to receive(:client).and_return(mock_client)
      allow(mock_client).to receive(:team_id).and_return('')
    end

    describe 'b2b_organization' do
      it 'parses the data correctly' do
        expect(b2b_organization).to be_instance_of(Spaceship::Tunes::B2bOrganization)
        expect(b2b_organization.type).to eq("DELETE")
        expect(b2b_organization.dep_customer_id).to eq("abcdefgh")
        expect(b2b_organization.dep_organization_id).to eq('1234567890')
        expect(b2b_organization.name).to eq('My awesome company')
      end
    end

    describe 'from_id_info' do
      it 'creates correct object' do
        b2b_org_created = Spaceship::Tunes::B2bOrganization.from_id_info(dep_id: 'jklmnopqr',
                                                                         dep_name: 'Another awesome company',
                                                                         type: Spaceship::Tunes::B2bOrganization::TYPE::ADD)
        expect(b2b_org_created.type).to eq("ADD")
        expect(b2b_org_created.dep_customer_id).to eq('jklmnopqr')
        expect(b2b_org_created.name).to eq('Another awesome company')
      end
    end

    describe '==' do
      it 'works correctly' do
        org1 = Spaceship::Tunes::B2bOrganization.new(
          'value' => {
              'type' => "DELETE",
              'depCustomerId' => 'abcdefgh',
              'organizationId' => '1234567890',
              'name' => 'My awesome company'
          }
        )
        org2 = Spaceship::Tunes::B2bOrganization.new(
          'value' => {
              'type' => "DELETE",
              'depCustomerId' => 'abcdefgh',
              'organizationId' => nil,
              'name' => 'My awesome company'
          }
        )
        org3 = Spaceship::Tunes::B2bOrganization.new(
          'value' => {
              'type' => "NO_CHANGE",
              'depCustomerId' => 'abcdefgh',
              'organizationId' => '1234567890',
              'name' => 'My awesome company'
          }
        )

        expect(org1 == org2).to eq(true)
        expect(org1 != org2).to eq(false)
        expect(org1 == org3).to eq(false)
      end
    end
  end
end
