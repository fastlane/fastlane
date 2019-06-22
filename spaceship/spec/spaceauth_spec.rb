require_relative 'tunes/tunes_stubbing'

describe Spaceship::SpaceauthRunner do
  let(:user_cookie) { TunesStubbing.itc_read_fixture_file('spaceauth_cookie.yml') }

  it 'uses all required cookies for fastlane session' do
    if FastlaneCore::Helper.mac?
      expect(Spaceship::Client::UserInterface).to receive(:interactive?).and_return(false)
    end
    expect_any_instance_of(Spaceship::Client).to receive(:store_cookie).exactly(2).times.and_return(user_cookie)

    expect do
      Spaceship::SpaceauthRunner.new.run
    end.to output(/export FASTLANE_SESSION=.*name: DES.*name: myacinfo.*name: dqsid.*/).to_stdout
  end
end
