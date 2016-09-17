describe Pilot::Options do
  before(:each) do
    ENV.delete('FASTLANE_TEAM_ID')
  end

  after(:each) do
    ENV.delete('FASTLANE_TEAM_ID')
  end

  it "accepts a developer portal team ID" do
    FastlaneCore::Configuration.create(Pilot::Options.available_options, { dev_portal_team_id: 'ABCD1234' })

    expect(ENV['FASTLANE_TEAM_ID']).to eq('ABCD1234')
  end
end
