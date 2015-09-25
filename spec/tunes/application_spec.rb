require 'spec_helper'

describe Spaceship::Application do
  before { Spaceship::Tunes.login }
  let(:client) { Spaceship::Application.client }

  describe "successfully loads and parses all apps" do
    it "inspect works" do
      expect(Spaceship::Application.all.first.inspect).to include("Tunes::Application")
    end

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

    it "#url" do
      expect(Spaceship::Application.all.first.url).to eq('https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/898536088')
    end

    describe "#find" do
      describe "find using bundle identifier" do
        it "returns the application if available" do
          a = Spaceship::Application.find('net.sunapps.107')
          expect(a.class).to eq(Spaceship::Application)
          expect(a.apple_id).to eq('898536088')
        end

        it "returns nil if not available" do
          a = Spaceship::Application.find('netnot.available')
          expect(a).to eq(nil)
        end
      end

      describe "find using Apple ID" do
        it "returns the application if available" do
          a = Spaceship::Application.find('898536088')
          expect(a.class).to eq(Spaceship::Application)
          expect(a.bundle_id).to eq('net.sunapps.107')
        end

        it "supports int parameters too" do
          a = Spaceship::Application.find(898536088)
          expect(a.class).to eq(Spaceship::Application)
          expect(a.bundle_id).to eq('net.sunapps.107')
        end
      end
    end

    describe "#create!" do
      it "works with valid data and defaults to English" do
        Spaceship::Tunes::Application.create!(name: "My name",
                                              version: "1.0",
                                              sku: "SKU123",
                                              bundle_id: "net.sunapps.123")
      end

      it "raises an error if something is wrong" do
        itc_stub_broken_create
        expect do
          Spaceship::Tunes::Application.create!(name: "My Name",
                                                version: "1.0",
                                                sku: "SKU123",
                                                bundle_id: "net.sunapps.123")
        end.to raise_error "You must choose a primary language. You must choose a primary language."
      end

      it "raises an error if bundle is wildcard and bundle_id_suffix has not specified" do
        itc_stub_broken_create_wildcard
        expect do
          Spaceship::Tunes::Application.create!(name: "My Name",
                                                version: "1.0",
                                                sku: "SKU123",
                                                bundle_id: "net.sunapps.*")
        end.to raise_error "You must enter a Bundle ID Suffix. You must enter a Bundle ID Suffix."
      end
    end

    describe "#create! first app (company name required)" do
      it "works with valid data and defaults to English" do
        itc_stub_applications_first_create
        Spaceship::Tunes::Application.create!(name: "My Name",
                                              version: "1.0",
                                              sku: "SKU123",
                                              bundle_id: "net.sunapps.123",
                                              company_name: "SunApps GmbH")
      end

      it "raises an error if something is wrong" do
        itc_stub_applications_broken_first_create
        expect do
          Spaceship::Tunes::Application.create!(name: "My Name",
                                                version: "1.0",
                                                sku: "SKU123",
                                                bundle_id: "net.sunapps.123")
        end.to raise_error "You must provide a company name to use on the App Store. You must provide a company name to use on the App Store."
      end
    end

    describe "#resolution_center" do
      it "when the app was rejected" do
        itc_stub_resolution_center
        result = Spaceship::Tunes::Application.all.first.resolution_center
        expect(result['appNotes']['threads'].first['messages'].first['body']).to include('Your app declares support for audio in the UIBackgroundModes')
      end

      it "when the app was not rejected" do
        itc_stub_resolution_center_valid
        expect(Spaceship::Tunes::Application.all.first.resolution_center).to eq({"sectionErrorKeys" => [], "sectionInfoKeys" => [], "sectionWarningKeys" => [], "replyConstraints" => {"minLength" => 1, "maxLength" => 4000}, "appNotes" => {"threads" => []}, "betaNotes" => {"threads" => []}, "appMessages" => {"threads" => []}})
      end
    end

    describe "#builds" do
      let(:app) { Spaceship::Application.all.first }

      it "supports block parameter" do
        count = 0
        app.builds do |current|
          count += 1
          expect(current.class).to eq(Spaceship::Tunes::Build)
        end
        expect(count).to eq(2)
      end

      it "returns a standard array" do
        expect(app.builds.count).to eq(2)
        expect(app.builds.first.class).to eq(Spaceship::Tunes::Build)
      end
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

      describe "#latest_version" do
        it "returns the edit_version if available" do
          app = Spaceship::Application.all.first
          expect(app.latest_version.class).to eq(Spaceship::Tunes::AppVersion)
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

    describe "Create new version" do
      it "raises an exception if there already is a new version" do
        app = Spaceship::Application.all.first
        expect do
          app.create_version!('0.1')
        end.to raise_error "Cannot create a new version for this app as there already is an `edit_version` available"
      end

      it "works if there is no `edit_version` already available" do
        app = Spaceship::Application.all.find { |a| a.apple_id == '1013943394' }
        expect(app.edit_version).to eq(nil)
        app.create_version!('0.1')
      end
    end
  end
end
