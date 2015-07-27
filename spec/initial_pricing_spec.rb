describe Deliver do
  describe Deliver::AppMetadata do
    before do
      @app = Deliver::App.new(apple_id: 794902327)
      @app.metadata = Deliver::AppMetadata.new(@app, "./spec/fixtures/exampleEmpty.itmsp/", false)
    end

    it "properly sets the initial pricing" do
      @app.metadata.update_price_tier(9)

      value = @app.metadata.fetch_value("//x:wholesale_price_tier").first.text
      expect(value).to eq(9.to_s)
    end
  end
end