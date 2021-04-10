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

  describe 'exports_to_clipboard option' do
    before :each do
      # Save clipboard
      @clipboard = `pbpaste`
    end

    after :each do
      # Restore clipboard
      require 'open3'
      Open3.popen3('pbcopy') { |input, _, _| input << @clipboard }
    end

    it 'when true, it should copy "export FASTLANE_SESSION=…" command to clipboard' do
      Spaceship::SpaceauthRunner.new(exports_to_clipboard: true).run
      expect(`pbpaste`).to match(/export FASTLANE_SESSION=.*/)
    end

    it 'when false, it should not copy "export FASTLANE_SESSION=…" command to clipboard' do
      Spaceship::SpaceauthRunner.new(exports_to_clipboard: false).run
      expect(`pbpaste`).to eq(@clipboard)
    end
  end
end
