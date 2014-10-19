describe Deliver do
  describe Deliver::Languages do
    it "all languages are available" do
      expect(Deliver::Languages::ALL_LANGUAGES.count).to be >= 28
    end
  end
end