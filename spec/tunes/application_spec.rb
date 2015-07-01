require 'spec_helper'

describe Spaceship::Application do
  before { Spaceship::Tunes.login }
  let(:client) { Spaceship::Application.client }

  describe "successfully loads and parses all apps" do
    it "the number is correct" do
      expect(Spaceship::Application.all.count).to eq(6)
    end

    it "parses application correctly" do
      app = Spaceship::Application.all.first

      expect(app.apple_id).to eq('898536088')
      expect(app.name).to eq('App Name 1')
      expect(app.platform).to eq('ios')
      expect(app.vendor_id).to eq('107')
      expect(app.bundle_id).to eq('net.sunapps.107')
      expect(app.last_modified).to eq(1435685244000)
      expect(app.issues_count).to eq(0)
      expect(app.app_icon_preview_url).to eq('https://is5-ssl.mzstatic.com/image/thumb/Purple3/v4/78/7c/b5/787cb594-04a3-a7ba-ac17-b33d1582ebc9/mzl.dbqfnkxr.png/340x340bb-80.png')
    end
  end
end
