describe IosDeployKit do
  describe IosDeployKit::Languages do
    it "all languages are available" do
      expect(IosDeployKit::Languages::ALL_LANGUAGES.count).to be >= 28
    end
  end
end