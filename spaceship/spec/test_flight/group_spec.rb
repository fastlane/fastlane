require 'spec_helper'

describe Spaceship::TestFlight::Group do
  let(:mock_client) { double('MockClient') }

  before do
    Spaceship::TestFlight::Base.client = mock_client
  end

  context 'attr_mapping' do
    let(:group) do
      Spaceship::TestFlight::Group.new({
        'id' => 1,
        'name' => 'Group 1',
        'appAdamId' => 123,
        'isDefaultExternalGroup' => false
      })
    end

    it 'has them' do
      expect(group.id).to eq(1)
      expect(group.name).to eq('Group 1')
      expect(group.app_id).to eq(123)
      expect(group.is_default_external_group).to eq(false)
    end
  end

  context 'collections' do
    before do
      mock_client_response(:get_groups, with: { app_id: 'app-id' }) do
        [
          {
            id: 1,
            name: 'Group 1',
            isDefaultExternalGroup: true
          },
          {
            id: 2,
            name: 'Group 2',
            isDefaultExternalGroup: false
          }
        ]
      end
      mock_client_response(:create_group_for_app, with: { app_id: 'app-id', group_name: 'group-name' }) do
        {
          id: 3,
          name: 'group-name',
          isDefaultExternalGroup: false
        }
      end
    end

    context '.all' do
      it 'returns all of the groups' do
        groups = Spaceship::TestFlight::Group.all(app_id: 'app-id')
        expect(groups.size).to eq(2)
        expect(groups.first).to be_instance_of(Spaceship::TestFlight::Group)
      end
    end

    context '.find' do
      it 'returns a Group by group_name' do
        group = Spaceship::TestFlight::Group.find(app_id: 'app-id', group_name: 'Group 1')
        expect(group).to be_instance_of(Spaceship::TestFlight::Group)
        expect(group.name).to eq('Group 1')
      end

      it 'returns nil if no group matches' do
        group = Spaceship::TestFlight::Group.find(app_id: 'app-id', group_name: 'Group NaN')
        expect(group).to be_nil
      end
    end

    context '.create!' do
      it 'returns an existing group with the same name' do
        group = Spaceship::TestFlight::Group.create!(app_id: 'app-id', group_name: 'Group 1')
        expect(group.name).to eq('Group 1')
        expect(group.id).to eq(1)
        expect(group).to be_instance_of(Spaceship::TestFlight::Group)
      end

      it 'creates the group for correct parameters' do
        group = Spaceship::TestFlight::Group.create!(app_id: 'app-id', group_name: 'group-name')
        expect(group.name).to eq('group-name')
        expect(group.id).to eq(3)
        expect(group).to be_instance_of(Spaceship::TestFlight::Group)
      end
    end

    context '.default_external_group' do
      it 'returns the default external group' do
        group = Spaceship::TestFlight::Group.default_external_group(app_id: 'app-id')
        expect(group).to be_instance_of(Spaceship::TestFlight::Group)
        expect(group.id).to eq(1)
      end
    end

    context '.filter_groups' do
      it 'applies block and returns filtered groups' do
        groups = Spaceship::TestFlight::Group.filter_groups(app_id: 'app-id') { |group| group.name == 'Group 1' }
        expect(groups).to be_instance_of(Array)
        expect(groups.size).to eq(1)
        expect(groups.first.id).to eq(1)
      end
    end
  end

  context 'instances' do
    let(:group) { Spaceship::TestFlight::Group.new('appAdamId' => 1, 'id' => 2, 'isDefaultExternalGroup' => true) }
    let(:tester) { double('Tester', tester_id: 'some-tester-id', first_name: 'first name', last_name: 'last name', email: 'some email') }

    context '#add_tester!' do
      it 'adds a tester via client' do
        expect(mock_client).to receive(:create_app_level_tester)
          .with(app_id: 1, first_name: tester.first_name, last_name: tester.last_name, email: tester.email)
          .and_return('id' => 'some-tester-id')
        expect(mock_client).to receive(:post_tester_to_group)
          .with(group_id: 2,
                   email: tester.email,
              first_name: tester.first_name,
               last_name: tester.last_name,
                  app_id: 1)
        group.add_tester!(tester)
      end
    end

    context '#remove_tester!' do
      it 'removes a tester via client' do
        expect(mock_client).to receive(:delete_tester_from_group).with(group_id: 2, tester_id: 'some-tester-id', app_id: 1)
        group.remove_tester!(tester)
      end
    end

    context '#default_external_group?' do
      it 'returns default_external_group' do
        expect(group).to receive(:is_default_external_group).and_call_original
        expect(group.default_external_group?).to be(true)
      end
    end
  end
end
