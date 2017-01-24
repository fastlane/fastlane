describe Spaceship::Tunes::AppIAP, all: true do
  before { Spaceship::Tunes.login }

  let(:app) { Spaceship::Application.all.first }

  describe "successfully loads and parses the in-app purchases" do
    it "inspect works" do
      expect(app.in_app_purchases[0].inspect).to include("Tunes::AppIAP")
    end

    it "parses the basic in-app purchase details correctly" do
      iap = app.in_app_purchases[0]

      expect(iap.application).to eq(app)
      expect(iap.reference_name).to eq('1 Week Subscription')
      expect(iap.vendor_id).to eq('seven_days')
      expect(iap.raw_status).to eq('readyForSale')
      expect(iap.raw_type).to eq('ITC.addons.type.recurring')
      expect(iap.duration_days).to eq(7)
    end

    describe "in-app-purchase status" do
      it "parses readyForSale" do
        iap = app.in_app_purchases[0]

        expect(iap.status).to eq("Approved")
        expect(iap.status).to eq(Spaceship::Tunes::IAPStatus::APPROVED)
      end

      it "parses missingMetadata" do
        expect(Spaceship::Tunes::IAPStatus.get_from_string('missingMetadata')).to eq(Spaceship::Tunes::IAPStatus::MISSING_METADATA)
      end

      it "parses waitingForReview" do
        iap = app.in_app_purchases[1]

        expect(iap.status).to eq("Waiting For Review")
        expect(iap.status).to eq(Spaceship::Tunes::IAPStatus::WAITING_FOR_REVIEW)
      end
    end

    describe "in-app-purchase type" do
      it "parses recurring" do
        iap = app.in_app_purchases[0]

        expect(iap.type).to eq("Auto-Renewable Subscription")
        expect(iap.type).to eq(Spaceship::Tunes::IAPType::AUTO_RENEWABLE_SUBSCRIPTION)
      end

      it "parses consumable" do
        expect(Spaceship::Tunes::IAPType.get_from_string('ITC.addons.type.consumable')).to eq(Spaceship::Tunes::IAPType::CONSUMABLE)
      end
    end
  end
end
