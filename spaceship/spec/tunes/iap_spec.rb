describe Spaceship::Tunes::IAP do
  before { Spaceship::Tunes.login }
  let(:client) { Spaceship::Tunes.client }
  let(:app) { Spaceship::Application.all.first }

  describe "returns all purchases" do
    it "returns as IAPList" do
      expect(app.in_app_purchases.all.first.class).to eq(Spaceship::Tunes::IAPList)
    end

    it "Finds a specific product" do
      expect(app.in_app_purchases.find("go.find.me")).not_to(eq(nil))
      expect(app.in_app_purchases.find("go.find.me").reference_name).to eq("localizeddemo")
    end

    it "Finds families" do
      expect(app.in_app_purchases.families.class).to eq(Spaceship::Tunes::IAPFamilies)
      expect(app.in_app_purchases.families.all.first.class).to eq(Spaceship::Tunes::IAPFamilyList)
      expect(app.in_app_purchases.families.all.first.name).to eq("Product name1234")
    end

    describe "Create new IAP" do
      it "create consumable" do
        expect(client.du_client).to receive(:get_picture_type).and_return("SortedScreenShot")
        expect(client.du_client).to receive(:upload_purchase_review_screenshot).and_return({ "token" => "tok", "height" => 100, "width" => 200, "md5" => "xxxx" })
        expect(Spaceship::UploadFile).to receive(:from_path).with("ftl_FAKEMD5_screenshot1024.jpg").and_return(du_uploadimage_correct_screenshot)
        app.in_app_purchases.create!(
          type: Spaceship::Tunes::IAPType::CONSUMABLE,
          versions: {
            'en-US' => {
              name: "test name1",
              description: "Description has at least 10 characters"
            },
            'de-DE' => {
              name: "test name german1",
              description: "German has at least 10 characters"
            }
          },
          reference_name: "localizeddemo",
          product_id: "x.a.a.b.b.c.d.x.y.f",
          cleared_for_sale: true,
          review_notes: "Some Review Notes here bla bla bla",
          review_screenshot: "ftl_FAKEMD5_screenshot1024.jpg",
          pricing_intervals:
            [
              {
                country: "WW",
                begin_date: nil,
                end_date: nil,
                tier: 1
              }
            ]
        )
      end
    end
  end
end
