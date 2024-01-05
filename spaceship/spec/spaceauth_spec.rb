require_relative 'tunes/tunes_stubbing'
require 'fastlane_core/clipboard'

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

  describe 'copy_to_clipboard option', if: FastlaneCore::Clipboard.is_supported? do
    before :each do
      # Save clipboard
      @clipboard = FastlaneCore::Clipboard.paste
    end

    after :each do
      # Restore clipboard
      FastlaneCore::Clipboard.copy(content: @clipboard)
    end

    it 'when true, it should copy the session to clipboard' do
      Spaceship::SpaceauthRunner.new(copy_to_clipboard: true).run
      expect(FastlaneCore::Clipboard.paste).to match(%r{.*domain: idmsa.apple.com.*path: \"\/appleauth\/auth\/\".*})
    end

    it 'when false, it should not copy the session to clipboard' do
      Spaceship::SpaceauthRunner.new(copy_to_clipboard: false).run
      expect(FastlaneCore::Clipboard.paste).to eq(@clipboard)
    end
  end

  describe 'check_session option' do
    before :each do
      Spaceship::Globals.check_session = true
    end

    after :each do
      Spaceship::Globals.check_session = false
    end

    it 'when using the default user, it should return a message saying the session is logged in with an exit code of 0' do
      expect do
        expect do
          Spaceship::SpaceauthRunner.new.run
        end.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(0)
        end
      end.to output(/Valid session found \(.*\). Exiting./).to_stdout
    end

    it 'when passed a known user, it should return a message saying the session is logged in with an exit code of 0' do
      expect do
        expect do
          Spaceship::SpaceauthRunner.new(username: 'spaceship@krausefx.com').run
        end.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(0)
        end
      end.to output(/Valid session found \(.*\). Exiting./).to_stdout
    end

    it 'when passed an unknown user, it should return a message saying no valid session found with an exit code of 1' do
      expect do
        expect do
          Spaceship::SpaceauthRunner.new(username: 'unknown-user').run
        end.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end
      end.to output(/No valid session found \(.*\). Exiting./).to_stdout
    end
  end

  describe '#session_string' do
    it 'should return the session when called after run' do
      expect(Spaceship::SpaceauthRunner.new.run.session_string).to match(%r{.*domain: idmsa.apple.com.*path: \"\/appleauth\/auth\/\".*})
    end

    it 'should throw when called before run' do
      expect(FastlaneCore::UI).to receive(:user_error!).with(/method called before calling `run` in `SpaceauthRunner`/).and_raise("boom")
      expect do
        Spaceship::SpaceauthRunner.new.session_string
      end.to raise_error("boom")
    end
  end
end
