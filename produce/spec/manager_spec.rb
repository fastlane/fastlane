describe Produce do
  before do
    stub_produce
  end
  describe "Manager" do
    it "should auto convert string hash keys to symbol keys" do
      Produce.config = {
        username: "helmut@januschka.com",
        enabled_features: { "data_protection" => "complete" },
        skip_itc: true
      }
      Produce::Manager.start_producing

      # this does not get triggerd - HELP
      # i would return true here, and check  if the `enabled_features` argument to create_new_app is the expected one
      # but it just does not get called.
      expect(Produce::DeveloperCenter).to receive(:create_new_app).with(anything).and_return(false)
    end
  end
end
