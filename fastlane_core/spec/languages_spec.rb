describe FastlaneCore do
  describe FastlaneCore::Languages do
    it "all languages are available" do
      expect(FastlaneCore::Languages::ALL_LANGUAGES.count).to be >= 27
    end
  end
end
