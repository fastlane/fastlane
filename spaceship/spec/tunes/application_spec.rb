describe Spaceship::Application do
  before { Spaceship::Tunes.login }
  let(:client) { Spaceship::Application.client }

  describe "successfully loads and parses all apps" do
    it "inspect works" do
      expect(Spaceship::Application.all.first.inspect).to include("Tunes::Application")
    end

    it "the number is correct" do
      expect(Spaceship::Application.all.count).to eq(8)
    end

    it "parses application correctly" do
      app = Spaceship::Application.all.first

      expect(app.apple_id).to eq('898536088')
      expect(app.name).to eq('App Name 1')
      expect(app.platform).to eq('ios')
      expect(app.vendor_id).to eq('107')
      expect(app.bundle_id).to eq('net.sunapps.107')
      expect(app.last_modified).to eq(1_435_685_244_000)
      expect(app.issues_count).to eq(0)
      expect(app.app_icon_preview_url).to eq('https://is5-ssl.mzstatic.com/image/thumb/Purple3/v4/78/7c/b5/787cb594-04a3-a7ba-ac17-b33d1582ebc9/mzl.dbqfnkxr.png/340x340bb-80.png')

      expect(app.raw_data['versionSets'].count).to eq(1)
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

        it "returns the application if available ignoring case" do
          a = Spaceship::Application.find('net.sunAPPs.107')
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
          a = Spaceship::Application.find(898_536_088)
          expect(a.class).to eq(Spaceship::Application)
          expect(a.bundle_id).to eq('net.sunapps.107')
        end
      end
    end

    describe "#create!" do
      it "works with valid data and defaults to English" do
        Spaceship::Tunes::Application.create!(name: "My name",
                                              sku: "SKU123",
                                              bundle_id: "net.sunapps.123")
      end

      it "raises an error if something is wrong" do
        TunesStubbing.itc_stub_broken_create
        expect do
          Spaceship::Tunes::Application.create!(name: "My Name",
                                                sku: "SKU123",
                                                bundle_id: "net.sunapps.123")
        end.to raise_error("You must choose a primary language. You must choose a primary language.")
      end

      it "raises an error if bundle is wildcard and bundle_id_suffix has not specified" do
        TunesStubbing.itc_stub_broken_create_wildcard
        expect do
          Spaceship::Tunes::Application.create!(name: "My Name",
                                                sku: "SKU123",
                                                bundle_id: "net.sunapps.*")
        end.to raise_error("You must enter a Bundle ID Suffix. You must enter a Bundle ID Suffix.")
      end
    end

    describe "#create! first app (company name required)" do
      it "works with valid data and defaults to English" do
        TunesStubbing.itc_stub_applications_first_create
        Spaceship::Tunes::Application.create!(name: "My Name",
                                              sku: "SKU123",
                                              bundle_id: "net.sunapps.123",
                                              company_name: "SunApps GmbH")
      end

      it "raises an error if something is wrong" do
        TunesStubbing.itc_stub_applications_broken_first_create
        expect do
          Spaceship::Tunes::Application.create!(name: "My Name",
                                                sku: "SKU123",
                                                bundle_id: "net.sunapps.123")
        end.to raise_error("You must provide a company name to use on the App Store. You must provide a company name to use on the App Store.")
      end
    end

    describe "#resolution_center" do
      it "when the app was rejected" do
        TunesStubbing.itc_stub_resolution_center
        result = Spaceship::Tunes::Application.all.first.resolution_center
        expect(result['appNotes']['threads'].first['messages'].first['body']).to include('Your app declares support for audio in the UIBackgroundModes')
      end

      it "when the app was not rejected" do
        TunesStubbing.itc_stub_resolution_center_valid
        expect(Spaceship::Tunes::Application.all.first.resolution_center).to eq({ "sectionErrorKeys" => [], "sectionInfoKeys" => [], "sectionWarningKeys" => [], "replyConstraints" => { "minLength" => 1, "maxLength" => 4000 }, "appNotes" => { "threads" => [] }, "betaNotes" => { "threads" => [] }, "appMessages" => { "threads" => [] } })
      end
    end

    describe "#builds" do
      let(:app) { Spaceship::Application.all.first }
      let(:mock_client) { double('MockClient') }

      require 'spec_helper'
      require_relative '../mock_servers'

      before do
        Spaceship::TestFlight::Base.client = mock_client
        mock_client_response(:get_build_trains) do
          ['1.0', '1.1']
        end

        mock_client_response(:get_builds_for_train, with: hash_including(train_version: '1.0')) do
          [
            {
              id: 1,
              appAdamId: 10,
              trainVersion: '1.0',
              uploadDate: '2017-01-01T12:00:00.000+0000',
              externalState: 'testflight.build.state.export.compliance.missing'
            }
          ]
        end

        mock_client_response(:get_builds_for_train, with: hash_including(train_version: '1.1')) do
          [
            {
              id: 2,
              appAdamId: 10,
              trainVersion: '1.1',
              uploadDate: '2017-01-02T12:00:00.000+0000',
              externalState: 'testflight.build.state.submit.ready'
            },
            {
              id: 3,
              appAdamId: 10,
              trainVersion: '1.1',
              uploadDate: '2017-01-03T12:00:00.000+0000',
              externalState: 'testflight.build.state.processing'
            }
          ]
        end
      end

      it "supports block parameter" do
        count = 0
        app.builds do |current|
          count += 1
          expect(current.class).to eq(Spaceship::TestFlight::Build)
        end
        expect(count).to eq(3)
      end

      it "returns a standard array" do
        expect(app.builds.count).to eq(3)
        expect(app.builds.first.class).to eq(Spaceship::TestFlight::Build)
      end
    end

    describe "Access app_versions" do
      describe "#edit_version" do
        it "returns the edit version if there is an edit version" do
          app = Spaceship::Application.all.first
          v = app.edit_version
          expect(v.class).to eq(Spaceship::AppVersion)
          expect(v.application).to eq(app)
          expect(v.description['German']).to eq("My title")
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

      describe "#live_version weirdities" do
        it "no live version if app isn't yet uploaded" do
          app = Spaceship::Application.find(1_000_000_000)
          expect(app.live_version).to eq(nil)
          expect(app.edit_version.is_live).to eq(false)
          expect(app.latest_version.is_live).to eq(false)
        end
      end

      describe "BUNDLES" do
        let(:bundle) { Spaceship::Application.find(928_444_013) }
        it "can find a bundle" do
          expect(bundle.raw_data['type']).to eq("iOS App Bundle")
        end

        it "fails to find the edit_version of a bundle" do
          expect do
            bundle.edit_version
          end.to raise_error('We do not support BUNDLE types right now')
        end

        it "fails to find the live_version of a bundle" do
          expect do
            bundle.live_version
          end.to raise_error('We do not support BUNDLE types right now')
        end
      end
    end

    describe "Create new version" do
      it "raises an exception if there already is a new version" do
        app = Spaceship::Application.all.first
        expect do
          app.create_version!('0.1')
        end.to raise_error("Cannot create a new version for this app as there already is an `edit_version` available")
      end
    end

    describe "Version history" do
      it "Parses history" do
        app = Spaceship::Application.all.first
        history = app.versions_history
        expect(history.count).to eq(9)

        v = history[0]
        expect(v.version_string).to eq("1.0")
        expect(v.version_id).to eq(812_627_411)

        v = history[7]
        expect(v.version_string).to eq("1.3")
        expect(v.version_id).to eq(815_048_522)
        expect(v.items.count).to eq(6)
        expect(v.items[1].state_key).to eq("waitingForReview")
        expect(v.items[1].user_name).to eq("joe@wewanttoknow.com")
        expect(v.items[1].user_email).to eq("joe@wewanttoknow.com")
        expect(v.items[1].date).to eq(1_449_330_388_000)

        v = history[8]
        expect(v.version_string).to eq("1.4.1")
        expect(v.version_id).to eq(815_259_390)
        expect(v.items.count).to eq(7)
        expect(v.items[3].state_key).to eq("pendingDeveloperRelease")
        expect(v.items[3].user_name).to eq("Apple")
        expect(v.items[3].user_email).to eq(nil)
        expect(v.items[3].date).to eq(1_450_461_891_000)
      end
    end

    describe "Promo codes" do
      let(:app) { Spaceship::Application.all.first }

      it "fetches remaining promocodes" do
        promocodes = app.promocodes
        expect(promocodes.count).to eq(1)
        expect(promocodes[0].app_id).to eq(816_549_081)
        expect(promocodes[0].app_name).to eq('DragonBox Numbers')
        expect(promocodes[0].version).to eq('1.5.0')
        expect(promocodes[0].platform).to eq('ios')
        expect(promocodes[0].number_of_codes).to eq(2)
        expect(promocodes[0].maximum_number_of_codes).to eq(100)
        expect(promocodes[0].contract_file_name).to eq('promoCodes/ios/spqr5/PromoCodeHolderTermsDisplay_en_us.html')
      end

      it "fetches promocodes history", focus: true do
        promocodes = app.promocodes_history
        expect(promocodes.count).to eq(7)

        promocodes = promocodes[4]

        expect(promocodes.effective_date).to eq(1_457_864_552_000)
        expect(promocodes.expiration_date).to eq(1_460_283_752_000)
        expect(promocodes.username).to eq('joe@wewanttoknow.com')

        expect(promocodes.codes.count).to eq(1)
        expect(promocodes.codes[0]).to eq('6J49JFRP----')
        expect(promocodes.version.app_id).to eq(816_549_081)
        expect(promocodes.version.app_name).to eq('DragonBox Numbers')
        expect(promocodes.version.version).to eq('1.5.0')
        expect(promocodes.version.platform).to eq('ios')
        expect(promocodes.version.number_of_codes).to eq(7)
        expect(promocodes.version.maximum_number_of_codes).to eq(100)
        expect(promocodes.version.contract_file_name).to eq('promoCodes/ios/spqr5/PromoCodeHolderTermsDisplay_en_us.html')
      end
    end

    describe "#availability" do
      let(:app) { Spaceship::Application.all.first }
      before { TunesStubbing.itc_stub_app_pricing_intervals }

      it "inspect works" do
        availability = app.availability
        expect(availability.inspect).to include("Tunes::Availability")
      end
    end

    describe "#update_availability" do
      let(:app) { Spaceship::Application.all.first }
      before { TunesStubbing.itc_stub_app_pricing_intervals }

      it "inspect works" do
        TunesStubbing.itc_stub_app_uninclude_future_territories

        availability = app.availability
        availability.include_future_territories = false
        availability = app.update_availability!(availability)
        expect(availability.inspect).to include("Tunes::Availability")
      end
    end
  end
end
