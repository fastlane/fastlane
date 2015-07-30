require 'spec_helper'

describe Spaceship::AppVersion do
  before { Spaceship::Tunes.login }

  let(:client) { Spaceship::AppVersion.client }
  let (:app) { Spaceship::Application.all.first }

  describe "successfully loads and parses the app version" do

    it "inspect works" do
      expect(app.edit_version.inspect).to include("Tunes::AppVersion")
    end

    it "parses the basic version details correctly" do
      version = app.edit_version

      expect(version.application).to eq(app)
      expect(version.is_live?).to eq(false)
      expect(version.copyright).to eq("2015 SunApps GmbH")
      expect(version.version_id).to eq(812106519)
      expect(version.primary_category).to eq('MZGenre.Reference')
      expect(version.secondary_category).to eq('MZGenre.Business')
      expect(version.raw_status).to eq('readyForSale')
      expect(version.can_reject_version).to eq(false)
      expect(version.can_prepare_for_upload).to eq(false)
      expect(version.can_send_version_live).to eq(false)
      expect(version.release_on_approval).to eq(true)
      expect(version.can_beta_test).to eq(true)
      expect(version.version).to eq('0.9.13')
      expect(version.supports_apple_watch).to eq(false)
      expect(version.app_icon_url).to eq('https://is3-ssl.mzstatic.com/image/thumb/Purple3/v4/02/88/4d/02884d3d-92ea-5e6a-2a7b-b19da39f73a6/pr_source.png/1024x1024ss-80.png')
      expect(version.app_icon_original_name).to eq('AppIconFull.png')
      expect(version.watch_app_icon_url).to eq('https://muycustomurl.com')
      expect(version.watch_app_icon_original_name).to eq('OriginalName.png')
    end

    it "parses the localized values correctly" do
      version = app.edit_version

      expect(version.name['English']).to eq('App Name 123')
      expect(version.name['German']).to eq("yep, that's the name")
      expect(version.description['English']).to eq('Super Description here')
      expect(version.description['German']).to eq('My title')
      expect(version.keywords['English']).to eq('Some random titles')
      expect(version.keywords['German']).to eq('More random stuff')
      expect(version.privacy_url['English']).to eq('http://privacy.sunapps.net')
      expect(version.support_url['German']).to eq('http://url.com')
      expect(version.marketing_url['English']).to eq('https://sunapps.net')
      expect(version.release_notes['German']).to eq('Wow, News')
      expect(version.release_notes['English']).to eq('Also News')

      expect(version.description.keys).to eq(version.description.languages)
      expect(version.description.keys).to eq(["German", "English"])
    end

    it "parses the review information correctly" do
      version = app.edit_version

      expect(version.review_first_name).to eq('Felix')
      expect(version.review_last_name).to eq('Krause')
      expect(version.review_phone_number).to eq('+4123123123')
      expect(version.review_email).to eq('felix@sunapps.net')
      expect(version.review_demo_user).to eq('MyUser@gmail.com')
      expect(version.review_demo_password).to eq('SuchPass')
      expect(version.review_notes).to eq('Such Notes here')
    end

    describe "#url" do
      it "live version" do
        expect(app.live_version.url).to eq('https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/898536088/cur')
      end

      it "edit version" do
        expect(app.edit_version.url).to eq('https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/898536088/')
      end
    end

    describe "App Status" do
      it "parses readyForSale" do
        version = app.live_version

        expect(version.app_status).to eq("Ready for Sale")
        expect(version.app_status).to eq(Spaceship::Tunes::AppStatus::READY_FOR_SALE)
      end

      it "parses readyForSale" do
        expect(Spaceship::Tunes::AppStatus.get_from_string('prepareForUpload')).to eq(Spaceship::Tunes::AppStatus::PREPARE_FOR_SUBMISSION)
      end
    end

    describe "Screenshots" do
      it "properly parses all the screenshots" do
        v = app.live_version

        # This app only has screenshots in the English version
        expect(v.screenshots['German']).to eq([])

        s1 = v.screenshots['English'].first
        expect(s1.device_type).to eq('iphone4')
        expect(s1.url).to eq('https://is1-ssl.mzstatic.com/image/thumb/Purple3/v4/31/8e/b4/318eb497-b57f-64e6-eaa0-94eff9cb7319/b6a876130fa48da21db6622f08b815b4.png/640x1136ss-80.png')
        expect(s1.thumbnail_url).to eq('https://is1-ssl.mzstatic.com/image/thumb/Purple3/v4/31/8e/b4/318eb497-b57f-64e6-eaa0-94eff9cb7319/b6a876130fa48da21db6622f08b815b4.png/500x500bb-80.png')
        expect(s1.sort_order).to eq(1)
        expect(s1.original_file_name).to eq('b6a876130fa48da21db6622f08b815b4.png')
        expect(s1.language).to eq('English')

        expect(v.screenshots['English'].count).to eq(8)

        # 2 iPhone 6 Plus Screenshots
        expect(v.screenshots['English'].find_all { |s| s.device_type == 'iphone6Plus' }.count).to eq(2)
      end
    end
  end

  describe "Modifying the app version" do
    let (:version) { Spaceship::Application.all.first.edit_version }

    it "doesn't allow modification of localized properties without the language" do
      begin
        version.name = "Yes"
        raise "Should raise exception before"
      rescue NoMethodError => ex
        expect(ex.to_s).to include("undefined method `name='")
      end
    end

    describe "Modifying the category" do
      it "prefixes the category with the correct value for all category types" do
        version.primary_category = "Weather"
        expect(version.primary_category).to eq("MZGenre.Weather")

        version.primary_first_sub_category = "Weather"
        expect(version.primary_first_sub_category).to eq("MZGenre.Weather")

        version.primary_second_sub_category = "Weather"
        expect(version.primary_second_sub_category).to eq("MZGenre.Weather")

        version.secondary_category = "Weather"
        expect(version.secondary_category).to eq("MZGenre.Weather")

        version.secondary_first_sub_category = "Weather"
        expect(version.secondary_first_sub_category).to eq("MZGenre.Weather")

        version.secondary_second_sub_category = "Weather"
        expect(version.secondary_second_sub_category).to eq("MZGenre.Weather")
      end

      it "doesn't prefix if the prefix is already there" do
        version.primary_category = "MZGenre.Weather"
        expect(version.primary_category).to eq("MZGenre.Weather")
      end
    end

    it "allows modifications of localized values" do
      new_title = 'New Title'
      version.name['English'] = new_title
      lang = version.languages.find { |a| a['language'] == 'English' }
      expect(lang['name']['value']).to eq(new_title)
    end

    describe "Pushing the changes back to the server" do
      it "raises an exception if there was an error" do
        itc_stub_invalid_update
        expect {
          version.save!
        }.to raise_error "The App Name you entered has already been used. The App Name you entered has already been used. You must provide an address line. There are errors on the page and for 2 of your localizations."
      end

      it "works with valid update data" do
        itc_stub_valid_update
        expect(client).to receive(:update_app_version!).with('898536088', false, version.raw_data)
        version.save!
      end
    end

    describe "Accessing different languages" do
      it "raises an exception if language is not available" do
        expect {
          version.name["English_CA"]
        }.to raise_error "Language 'English_CA' is not activated for this app version."
      end

      # it "allows the creation of a new language" do
      #   version.create_languages!(['German', 'English_CA'])
      #   expect(version.name['German']).to eq("yep, that's the name")
      #   expect(version.name['English_CA']).to eq("yep, that's the name")
      # end
    end
  end
end
