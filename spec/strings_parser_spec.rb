describe Frameit do
  describe Frameit::ConfigParser do
    describe "parse" do
      it "raise error when file can't be found" do
        expect {
          Frameit::StringsParser.parse("./nothere")
        }.to raise_exception "Couldn't find strings file at path './nothere'".red
      end

      it "raise error when file isn't a .strings file" do
        expect {
          Frameit::StringsParser.parse("./spec/fixtures/background.jpg")
        }.to raise_exception "Must be .strings file, only got './spec/fixtures/background.jpg'".red
      end

      describe "successfully parsing" do
        it "parses a valid .strings file" do
          translations = Frameit::StringsParser.parse("./spec/fixtures/translations.strings")

          expect(translations).to eq({
            "Cancel" => "Abbrechen", 
            "OK" => "OK", 
            "Multiple words working" => "einlangesdeutshceswort mit Abstand"
          })
        end
      end
    end
  end
end