require 'spec_helper'

describe Spaceship::Tunes::Build do
  before { Spaceship::Tunes.login }
  subject { Spaceship::Tunes.client }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  describe "properly parses the build from the train" do
    let (:app) { Spaceship::Application.all.first }

    it "filled in all required values" do
      train = app.build_trains.first
      build = train.builds.first

      expect(build.build_train).to eq(train)
      expect(build.upload_date).to eq(1413966436000)
      expect(build.valid).to eq(true)
      expect(build.id).to eq(523299)
      expect(build.build_version).to eq("123123")
      expect(build.train_version).to eq("0.9.10")
      expect(build.upload_date).to eq(1413966436000)
      expect(build.icon_url).to eq('https://is5-ssl.mzstatic.com/image/thumb/Newsstand5/v4/e8/ab/f8/e8abf8ca-6c22-a519-aa1b-c73901c4917e/Icon-60@2x.png.png/150x150bb-80.png')
      expect(build.app_name).to eq('Yeahaa')
      expect(build.platform).to eq('ios')
      expect(build.internal_expiry_date).to eq(1416562036000)
      expect(build.watch_kit_enabled).to eq(false)
      expect(build.ready_to_install).to eq(false)

      # Analytics
      expect(build.install_count).to eq(0)
      expect(build.internal_install_count).to eq(0)
      expect(build.external_install_count).to eq(0)
      expect(build.session_count).to eq(nil)
      expect(build.crash_count).to eq(nil)
    end
  end
end
