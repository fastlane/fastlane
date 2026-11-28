describe Spaceship::Tunes::IAPFamilyList do
  before { TunesStubbing.itc_stub_iap }
  include_examples "common spaceship login"
  let(:client) { Spaceship::Application.client }
  let(:app) { Spaceship::Application.all.find { |a| a.apple_id == "898536088" } }
  let(:purchase) { app.in_app_purchases }
  describe "IAP FamilyList" do
    it "Creates a Object" do
      element = app.in_app_purchases.families.all.first
      expect(element.class).to eq(Spaceship::Tunes::IAPFamilyList)
      expect(element.name).to eq("Product name1234")
    end
    it "Loads Edit Version" do
      edit_version = app.in_app_purchases.families.all.first.edit
      expect(edit_version.class).to eq(Spaceship::Tunes::IAPFamilyDetails)
      expect(edit_version.family_id).to eq("20373395")
    end
  end
end
