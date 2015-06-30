require 'spec_helper'

describe Spaceship::AppVersion do
  before { Spaceship::Tunes.login }
  let(:client) { Spaceship::AppVersion.client }

  describe "successfully loads and parses the app version" do
    it "parses application correctly" do
      app = Spaceship::Application.all.first

      version = app.edit_version

      expect(version.application).to eq(app)
      expect(version.is_live?).to eq(false)
      expect(version.primary_category).to eq('MZGenre.Reference')
      expect(version.secondary_category).to eq('MZGenre.Business')
      expect(version.status).to eq('readyForSale')
      expect(version.can_reject_version).to eq(false)
      expect(version.can_prepare_for_upload).to eq(false)
      expect(version.can_send_version_live).to eq(false)

      # Multi Lang
      expect(version.name['English']).to eq('App Name 123')
      expect(version.name['German']).to eq("yep, that's the name")
      expect(version.description['English']).to eq('Super Description here')
      expect(version.description['German']).to eq('My title')
      expect(version.keywords['English']).to eq('Some random titles')
      expect(version.keywords['German']).to eq('More random stuff')
      expect(version.privacy_url['English']).to eq('http://privacy.sunapps.net')
      expect(version.support_url['German']).to eq('http://url.com')
      expect(version.marketing_url['English']).to eq('https://sunapps.net')
    end

    it "allows modifications of localized values" do
      app = Spaceship::Application.all.first
      version = app.edit_version

      new_title = 'New Title'
      version.name['English'] = new_title
      lang = version.languages.find { |a| a['language'] == 'English' }
      expect(lang['name']['value']).to eq(new_title)
    end
  end
end
