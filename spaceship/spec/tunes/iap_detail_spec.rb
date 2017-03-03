describe Spaceship::Tunes::IAPDetail do
  before { Spaceship::Tunes.login }
  let(:client) { Spaceship::Application.client }
  let(:app) { Spaceship::Application.all.first }
  let(:detailed) { app.in_app_purchases.find("go.find.me").edit }
  describe "Details of an IAP" do
    it "Loads full details of a single iap" do
      detailed = app.in_app_purchases.find("go.find.me").edit
      expect(detailed.class).to eq(Spaceship::Tunes::IAPDetail)
      expect(detailed.reference_name).to eq("created by spaceship")
    end
    it "Read language versions" do
      expect(detailed.versions["de-DE".to_sym][:name]).to eq("test name german1")
    end
    it "humanizes status" do
      expect(detailed.status).to eq("Ready to Submit")
    end
    it "humanizes type" do
      expect(detailed.type).to eq("Consumable")
    end

    it "read pricing_intervals" do
      expect(detailed.pricing_intervals.first[:tier]).to eq(1)
      expect(detailed.pricing_intervals.first[:country]).to eq("WW")
    end
  end
  describe "modification" do
    it "saved" do
      detailed.cleared_for_sale = false
      expect(client).to receive(:update_iap!).with(app_id: '898536088', purchase_id: "1195137656", data: detailed.raw_data)
      detailed.save!
    end
    it "saved and changed screenshot" do
      detailed.review_screenshot = "/tmp/fastlane_tests"
      expect(client.du_client).to receive(:upload_purchase_review_screenshot).and_return({ "token" => "tok", "height" => 100, "width" => 200, "md5" => "xxxx" })
      expect(Spaceship::Utilities).to receive(:content_type).and_return("image/jpg")
      expect(client).to receive(:update_iap!).with(app_id: '898536088', purchase_id: "1195137656", data: detailed.raw_data)
      detailed.save!
    end
    it "saved with subscription priceing goal" do
      expect(client).to receive(:update_iap!).with(app_id: '898536088', purchase_id: "1195137656", data: detailed.raw_data)
      detailed.subscription_price_target = { currency: "EUR", tier: 1 }
      detailed.save!
    end
  end
  describe "Deletion" do
    it "delete" do
      expect(client).to receive(:delete_iap!).with(app_id: '898536088', purchase_id: "1195137656")
      detailed.delete!
    end
  end
end
