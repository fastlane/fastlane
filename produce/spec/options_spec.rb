describe Produce do
  describe Produce::Options do
    before(:each) do
      ENV.delete('FASTLANE_ITC_TEAM_ID')
    end

    after(:each) do
      ENV.delete('FASTLANE_ITC_TEAM_ID')
    end

    describe ":itc_team_id" do
      it "accepts String" do
        options = { itc_team_id: "1234" }
        Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, options)

        expect(Produce.config[:itc_team_id]).to eq("1234")
      end

      it "accepts Integer" do
        options = { itc_team_id: 1234 }
        Produce.config = FastlaneCore::Configuration.create(Produce::Options.available_options, options)

        expect(Produce.config[:itc_team_id]).to eq(1234)
      end
    end
  end
end
