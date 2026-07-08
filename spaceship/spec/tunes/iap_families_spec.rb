describe Spaceship::Tunes::IAPFamilies do
  before { TunesStubbing.itc_stub_iap }
  include_examples "common spaceship login"
  let(:client) { Spaceship::Application.client }
  let(:app) { Spaceship::Application.all.find { |a| a.apple_id == "898536088" } }
  let(:purchase) { app.in_app_purchases }
  describe "Subscription Families" do
    it "Loads IAP Families List" do
      list = purchase.families.all
      expect(list.kind_of?(Array)).to eq(true)
      expect(list.first.name).to eq("Product name1234")
    end

    it "Creates a new IAP Subscription Family" do
      purchase.families.create!(
        reference_name: "First Product in Family",
        product_id: "new.product",
        name: "Family Name",
        versions: {
          'de-DE' => {
            subscription_name: "Subname German",
            name: 'App Name German'
          },
          'da' => {
            subscription_name: "Subname DA",
            name: 'App Name DA'
          }
        }
      )
    end
  end
end
