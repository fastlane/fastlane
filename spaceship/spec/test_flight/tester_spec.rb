require 'spec_helper'

describe Spaceship::TestFlight::Tester do
  let(:mock_client) { double('MockClient') }

  before do
    Spaceship::TestFlight::Base.client = mock_client
  end

  context 'attr_mapping' do
    let(:tester) do
      Spaceship::TestFlight::Tester.new({
        'id' => 1,
        'email' => 'email@domain.com'
      })
    end

    it 'has them' do
      expect(tester.tester_id).to eq(1)
      expect(tester.email).to eq('email@domain.com')
    end
  end

  context 'collections' do
    before do
      mock_client_response(:testers_for_app, with: { app_id: 'app-id' }) do
        [
          {
            id: 1,
            email: "email_1@domain.com"
          },
          {
            id: 2,
            email: 'email_2@domain.com'
          }
        ]
      end

      mock_client_response(:search_for_tester_in_app, with: { app_id: 'app-id', text: 'email_1@domain.com' }) do
        [
          {
            id: 1,
            email: "email_1@domain.com"
          }
        ]
      end

      mock_client_response(:search_for_tester_in_app, with: { app_id: 'app-id', text: 'EmAiL_3@domain.com' }) do
        [
          {
            id: 3,
            email: "EmAiL_3@domain.com"
          },
          {
            id: 4,
            email: "tacos_email_3@domain.com"
          }
        ]
      end

      mock_client_response(:search_for_tester_in_app, with: { app_id: 'app-id', text: 'taquito' }) do
        [
          {
            id: 1,
            email: "taquito@domain.com"
          },
          {
            id: 2,
            email: "taquitos@domain.com"
          }

        ]
      end

      mock_client_response(:search_for_tester_in_app, with: { app_id: 'app-id', text: 'NaN@domain.com' }) do
        []
      end
    end

    context '.all' do
      it 'returns all of the testers' do
        groups = Spaceship::TestFlight::Tester.all(app_id: 'app-id')
        expect(groups.size).to eq(2)
        expect(groups).to all(be_instance_of(Spaceship::TestFlight::Tester))
      end
    end

    context '.find' do
      it 'returns a Tester by email address' do
        tester = Spaceship::TestFlight::Tester.find(app_id: 'app-id', email: 'email_1@domain.com')
        expect(tester).to be_instance_of(Spaceship::TestFlight::Tester)
        expect(tester.tester_id).to be(1)
      end

      it 'returns nil if no Tester matches' do
        tester = Spaceship::TestFlight::Tester.find(app_id: 'app-id', email: 'NaN@domain.com')
        expect(tester).to be_nil
      end
    end

    context '.search' do
      it 'returns a Tester by email address' do
        testers = Spaceship::TestFlight::Tester.search(app_id: 'app-id', text: 'email_1@domain.com')
        expect(testers.length).to be(1)
        expect(testers.first).to be_instance_of(Spaceship::TestFlight::Tester)
        expect(testers.first.tester_id).to be(1)
      end

      it 'returns a Tester by email address if exact match case-insensitive' do
        testers = Spaceship::TestFlight::Tester.search(app_id: 'app-id', text: 'EmAiL_3@domain.com', is_email_exact_match: true)
        expect(testers.length).to be(1)
        expect(testers.first).to be_instance_of(Spaceship::TestFlight::Tester)
        expect(testers.first.tester_id).to be(3)
        expect(testers.first.email).to eq("EmAiL_3@domain.com")
      end

      it 'returns empty array if no Tester matches' do
        testers = Spaceship::TestFlight::Tester.search(app_id: 'app-id', text: 'NaN@domain.com')
        expect(testers.length).to be(0)
      end

      it 'returns two testers if two testers match full-text search' do
        testers = Spaceship::TestFlight::Tester.search(app_id: 'app-id', text: 'taquito')
        expect(testers.length).to be(2)
        expect(testers).to all(be_instance_of(Spaceship::TestFlight::Tester))
      end
    end
  end

  context 'instances' do
    let(:tester) { Spaceship::TestFlight::Tester.new('id' => 2, 'email' => 'email@domain.com') }

    context '.remove_from_app!' do
      it 'removes a tester from the app' do
        expect(mock_client).to receive(:delete_tester_from_app).with(app_id: 'app-id', tester_id: 2)
        tester.remove_from_app!(app_id: 'app-id')
      end
    end
  end

  context 'invites' do
    let(:tester) { Spaceship::TestFlight::Tester.new('id' => 'tester-id') }

    context '.resend_invite' do
      it 'suceeds' do
        expect(mock_client).to receive(:resend_invite_to_external_tester).with(app_id: 'app-id', tester_id: 'tester-id')
        tester.resend_invite(app_id: 'app-id')
      end
    end
  end
end
