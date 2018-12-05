describe Produce do
  describe Produce::Options do
    describe ":itc_team_id" do
      it "accepts String" do
        options = { itc_team_id: "12345" }
        Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, options)

        expect(Produce.config[:itc_team_id]).to eq("12345")
      end

      it "accepts Integer" do
        options = { itc_team_id: 12_345 }
        Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, options)

        expect(Produce.config[:itc_team_id]).to eq(12_345)
      end
    end
  end
end
