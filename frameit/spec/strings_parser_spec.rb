describe Frameit do
  describe Frameit::StringsParser do
    describe "parse" do
      it "raise error when file can't be found" do
        expect do
          Frameit::StringsParser.parse("./nothere")
        end.to raise_exception("Couldn't find strings file at path './nothere'")
      end

      it "raise error when file isn't a .strings file" do
        expect do
          Frameit::StringsParser.parse("./frameit/spec/fixtures/background.jpg")
        end.to raise_exception("Must be .strings file, only got './frameit/spec/fixtures/background.jpg'")
      end

      describe "successfully parsing" do
        it "parses a valid .strings file" do
          translations = Frameit::StringsParser.parse("./frameit/spec/fixtures/translations.strings")

          expect(translations).to eq({
            "Cancel" => "Abbrechen",
            "OK" => "OK",
            "Multiple words working" => "einlangesdeutshceswort mit Abstand"
          })
        end
      end

      describe "failure parsing" do
        it "logs a helpful message on a bad file" do
          expect(Frameit::UI).to receive(:error).with(/.*translations.bad.strings line 2:/)
          expect(Frameit::UI).to receive(:verbose).with(/undefined method .\[\]. for nil:NilClass/)
          expect(Frameit::UI).to receive(:error).with(/Empty parsing result for .*translations.bad.strings/)

          translations = Frameit::StringsParser.parse("./frameit/spec/fixtures/translations.bad.strings")
          expect(translations). to eq({})
        end

        it "explains that only UTF-16 is allowed if a UTF-8 encoded, but otherwise valid file is parsed" do
          expect(Frameit::UI).to receive(:error).with(/.*translations.utf8.strings.*UTF16/)

          translations = Frameit::StringsParser.parse("./frameit/spec/fixtures/translations.utf8.strings")
          expect(translations). to eq({})
        end
      end
    end
  end
end
