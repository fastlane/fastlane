describe Deliver do
  describe Deliver::AppMetadata do
    before do
      @app = Deliver::App.new(apple_id: 794902327)
      @app.metadata = Deliver::AppMetadata.new(@app, "./spec/fixtures/exampleEmpty.itmsp/", false)
    end

    it "properly sets the initial pricing" do
      @app.metadata.update_price_tier(9)

      expect(@app.metadata.fetch_value("//x:wholesale_price_tier").first.text).to eq(9.to_s)
      expect(@app.metadata.fetch_value("//x:territory").first.text).to eq("WW")
      expect(@app.metadata.fetch_value("//x:cleared_for_sale").first.text).to eq(true.to_s)
      expect(@app.metadata.fetch_value("//x:sales_start_date").first.text).to eq("2015-01-01")
      expect(@app.metadata.fetch_value("//x:start_date").first.text).to eq("2015-01-01")
      expect(@app.metadata.fetch_value("//x:allow_volume_discount").first.text).to eq(true.to_s)
    end
  end
end