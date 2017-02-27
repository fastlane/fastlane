describe Spaceship::Tunes::LanguageItem do
  before do
    Spaceship::Tunes.login
  end

  describe "#inspect" do
    it "prints out all languages with their values" do
      str = Spaceship::Application.all.first.edit_version.description.inspect
      expect(str).to eq("German: My title\nEnglish: Super Description here\n")
    end
  end
end
