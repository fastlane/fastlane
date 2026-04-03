describe Spaceship::Tunes::IAP do
  before { TunesStubbing.itc_stub_iap }
  include_examples "common spaceship login"
  let(:client) { Spaceship::Tunes.client }
  let(:app) { Spaceship::Application.all.find { |a| a.apple_id == "898536088" } }

  describe "returns all purchases" do
    it "returns as IAPList" do
      expect(app.in_app_purchases.all.first.class).to eq(Spaceship::Tunes::IAPList)
    end

    it "Finds shared secret key" do
      secret = app.in_app_purchases.get_shared_secret
      expect(secret.class).to eq(String)
      expect(secret.length).to be(32)
    end

    it "Generates new shared secret key" do
      old_secret = app.in_app_purchases.get_shared_secret
      new_secret = app.in_app_purchases.generate_shared_secret
      expect(old_secret).not_to(eq(new_secret))
      expect(new_secret.class).to eq(String)
      expect(new_secret.length).to be(32)
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

      it "create auto renewable subscription with pricing" do
        pricing_intervals = [
          {
            country: "WW",
            begin_date: nil,
            end_date: nil,
            tier: 1
          }
        ]
        transformed_pricing_intervals = pricing_intervals.map do |interval|
          {
            "value" =>  {
              "tierStem" =>  interval[:tier],
              "priceTierEffectiveDate" =>  interval[:begin_date],
              "priceTierEndDate" =>  interval[:end_date],
              "country" =>  interval[:country] || "WW",
              "grandfathered" =>  interval[:grandfathered]
            }
          }
        end
        expect(client).to receive(:update_recurring_iap_pricing!).with(app_id: '898536088', purchase_id: "1195137657", pricing_intervals: transformed_pricing_intervals)

        app.in_app_purchases.create!(
          type: Spaceship::Tunes::IAPType::RECURRING,
          versions: {
            'en-US' => {
              name: "test name2",
              description: "Description has at least 10 characters"
            },
            'de-DE' => {
              name: "test name german2",
              description: "German has at least 10 characters"
            }
          },
          reference_name: "localizeddemo",
          product_id: "x.a.a.b.b.c.d.x.y.z",
          cleared_for_sale: true,
          review_notes: "Some Review Notes here bla bla bla",
          pricing_intervals: pricing_intervals
        )
      end

      it "create auto renewable subscription with subscription price target" do
        subscription_price_target = {
          currency: "EUR",
          tier: 1
        }

        price_goal = TunesStubbing.itc_read_fixture_file('iap_price_goal_calc.json')
        transformed_pricing_intervals = JSON.parse(price_goal)["data"].map do |language_code, value|
          {
            "value" => {
              "tierStem" => value["tierStem"],
              "priceTierEffectiveDate" => value["priceTierEffectiveDate"],
              "priceTierEndDate" => value["priceTierEndDate"],
              "country" => language_code,
              "grandfathered" => { "value" => "FUTURE_NONE" }
            }
          }
        end
        expect(client).to receive(:update_recurring_iap_pricing!).with(app_id: '898536088',
          purchase_id: "1195137657", pricing_intervals: transformed_pricing_intervals)

        app.in_app_purchases.create!(
          type: Spaceship::Tunes::IAPType::RECURRING,
          versions: {
            'en-US' => {
              name: "test name2",
              description: "Description has at least 10 characters"
            },
            'de-DE' => {
              name: "test name german2",
              description: "German has at least 10 characters"
            }
          },
          reference_name: "localizeddemo",
          product_id: "x.a.a.b.b.c.d.x.y.z",
          cleared_for_sale: true,
          review_notes: "Some Review Notes here bla bla bla",
          subscription_price_target: subscription_price_target
        )
      end
    end
  end
end
