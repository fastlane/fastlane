describe Spaceship::ConnectAPI::AgeRatingDeclaration do
  let(:from_itc) do
    {
      "MZGenre.CARTOON_FANTASY_VIOLENCE" => 0,
      "REALISTIC_VIOLENCE" => 1,
      "HORROR" => 2,
      "UNRESTRICTED_WEB_ACCESS" => 1,
      "profanityOrCrudeHumor" => "NONE"
    }
  end

  let(:asc_1_2_false_gambling) do
    {
      "gamblingAndContests" => false
    }
  end

  let(:asc_1_2_true_gambling) do
    {
      "gamblingAndContests" => true
    }
  end

  describe "Helpers" do
    describe "#map_deprecation_if_possible" do
      it "successful migration of gamblingAndContests" do
        hash, messages, errors = Spaceship::ConnectAPI::AgeRatingDeclaration.map_deprecation_if_possible(asc_1_2_false_gambling)

        expect(hash).to eq({
          "gambling" => false,
          "contests" => "NONE"
        })
        expect(messages).to eq([
                                 "Age Rating 'gamblingAndContests' has been deprecated and split into 'gambling' and 'contests'"
                               ])
        expect(errors).to eq([])
      end

      it "unsuccessful migration of gamblingAndContests" do
        hash, messages, errors = Spaceship::ConnectAPI::AgeRatingDeclaration.map_deprecation_if_possible(asc_1_2_true_gambling)

        expect(hash).to eq({
          "gambling" => true,
          "contests" => true
        })
        expect(messages).to eq([
                                 "Age Rating 'gamblingAndContests' has been deprecated and split into 'gambling' and 'contests'"
                               ])
        expect(errors).to eq([
                               "'gamblingAndContests' could not be mapped to 'contests' - 'contests' requires a value of 'NONE', 'INFREQUENT_OR_MILD', or 'FREQUENT_OR_INTENSE'"
                             ])
      end
    end

    it "#map_key_from_itc" do
      keys = from_itc.keys.map do |key|
        Spaceship::ConnectAPI::AgeRatingDeclaration.map_key_from_itc(key)
      end

      expect(keys).to eq([
                           "violenceCartoonOrFantasy",
                           "violenceRealistic",
                           "horrorOrFearThemes",
                           "unrestrictedWebAccess",
                           "profanityOrCrudeHumor"
                         ])
    end

    it "#map_value_from_itc" do
      values = from_itc.map do |key, value|
        key = Spaceship::ConnectAPI::AgeRatingDeclaration.map_key_from_itc(key)
        Spaceship::ConnectAPI::AgeRatingDeclaration.map_value_from_itc(key, value)
      end

      expect(values).to eq([
                             "NONE",
                             "INFREQUENT_OR_MILD",
                             "FREQUENT_OR_INTENSE",
                             true,
                             "NONE"
                           ])
    end
  end
end
