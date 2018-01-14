describe Spaceship::Tunes::IAPList do
  before { Spaceship::Tunes.login }
  let(:client) { Spaceship::Application.client }
  let(:app) { Spaceship::Application.all.first }
  let(:purchase) { app.in_app_purchases }
  describe "IAPList" do
    it "Creates a Object" do
      element = app.in_app_purchases.find("go.find.me")
      expect(element.class).to eq(Spaceship::Tunes::IAPList)
      expect(element.product_id).to eq("go.find.me")
      expect(element.status).to eq("Missing Metadata")
      expect(element.type).to eq("Consumable")
    end
    it "Loads Edit Version" do
      edit_version = app.in_app_purchases.find("go.find.me").edit
      expect(edit_version.class).to eq(Spaceship::Tunes::IAPDetail)
      expect(edit_version.product_id).to eq("go.find.me")
    end
    it "Loads Edit Version of Recurring IAP" do
      edit_version = app.in_app_purchases.find("x.a.a.b.b.c.d.x.y.z").edit
      expect(edit_version.class).to eq(Spaceship::Tunes::IAPDetail)
      expect(edit_version.product_id).to eq("x.a.a.b.b.c.d.x.y.z")
      expect(edit_version.pricing_intervals[0][:tier]).to eq(2)
      expect(edit_version.pricing_intervals[0][:country]).to eq("BB")
    end
    it "can delete" do
      deleted = app.in_app_purchases.find("go.find.me").delete!
      expect(deleted).to eq(nil)
    end
  end
end
