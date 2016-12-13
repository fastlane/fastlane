describe Spaceship::Tunes::Application do
  before { Spaceship::Tunes.login }
  subject { Spaceship::Tunes.client }
  let(:username) { 'spaceship@krausefx.com' }
  let(:password) { 'so_secret' }

  describe "All Builds" do
    let(:app) { Spaceship::Application.all.first }

    before do
      TunesStubbing.itc_stub_build_details
    end

    it "#all_build_train_numbers" do
      result = app.all_build_train_numbers
      expect(result).to eq(["2.0.1", "2.0"])
    end

    it "#all_builds_for_train" do
      result = app.all_builds_for_train(train: "2.0.1").first
      expect(result.apple_id).to eq("898536088")
      expect(result.id).to eq(123_123)
      expect(result.build_version).to eq("4")
      expect(result.train_version).to eq("2.0.1")
    end

    it "access build details and dSYM URL" do
      result = app.all_builds_for_train(train: "2.0.1").first
      details = result.details
      expect(details.apple_id).to eq("898536088")
      expect(details.dsym_url).to eq("http://iosapps.itunes.apple.com/apple-assets-us-std-000001/Purple3/v4/57/d2/d8/57d2d873-e24b-75a2-asdfs-621628a10518/dSYMs?accessKey=lkjsdfjLKJlKJLKJDSFSDJF")
      expect(details.include_symbols).to eq(false)
      expect(details.number_of_asset_packs).to eq(1)
      expect(details.contains_odr).to eq(false)
      expect(details.build_sdk).to eq("13A340")
      expect(details.file_name).to eq("AppName.ipa")
    end
  end
end
