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

      expect(app.raw_data['versions'].count).to eq(2)
    end

    describe "Access app_versions" do
      describe "#edit_version" do
        it "returns nil if there is only a live version" do
          app = Spaceship::Application.all.find { |a| a.apple_id == '1013943394' }
          expect(app.edit_version).to eq(nil)
        end

        it "returns the edit version if there is an edit version" do
          app = Spaceship::Application.all.first
          v = app.edit_version
          expect(v.class).to eq(Spaceship::AppVersion)
          expect(v.application).to eq(app)
          expect(v.name['German']).to eq("yep, that's the name")
          expect(v.is_live).to eq(false)
        end
      end

      describe "#live_version" do
        it "there is always a live version" do
          v = Spaceship::Application.all.first.live_version
          expect(v.class).to eq(Spaceship::AppVersion)
          expect(v.is_live).to eq(true)
        end
      end
    end

    describe "Create new version", now: true do
      it "raises an exception if there already is a new version" do
        app = Spaceship::Application.all.first
        expect {
          app.create_version!('0.1')
        }.to raise_error "Cannot create a new version for this app as there already is an `edit_version` available"
      end

      it "works if there is no `edit_version` already available" do
        app = Spaceship::Application.all.find { |a| a.apple_id == '1013943394' }
        expect(app.edit_version).to eq(nil)
        app.create_version!('0.1')
      end
    end
  end
end
