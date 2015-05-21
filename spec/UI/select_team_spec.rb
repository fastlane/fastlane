require 'spec_helper'

describe Spaceship::Client do
  describe "UI" do
    describe "#select_team" do
      subject { Spaceship.client }
      let(:username) { 'spaceship@krausefx.com' }
      let(:password) { 'so_secret' }

      before do
        Spaceship.login
        client = Spaceship.client
      end

      it "uses the first team if there is only one" do
        expect(subject.select_team).to eq("XXXXXXXXXX")
      end

      it "lets the user select the team if in multiple teams" do
        stub_request(:post, 'https://developer.apple.com/services-account/QH65B2/account/listTeams.action').
            to_return(:status => 200, :body => read_fixture_file('listTeams_multiple.action.json'), :headers => {'Content-Type' => 'application/json'})
        
        allow($stdin).to receive(:gets).and_return("2")
        expect(subject.select_team).to eq("SecondTeam") # a different team
      end
    end
  end
end
