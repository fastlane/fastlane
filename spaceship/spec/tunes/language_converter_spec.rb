describe Spaceship::Tunes::LanguageConverter do
  let(:klass) { Spaceship::Tunes::LanguageConverter }

  describe "#from_itc_to_standard" do
    it "works with valid inputs" do
      expect(klass.from_itc_to_standard('English')).to eq('en-US')
      expect(klass.from_itc_to_standard('English_CA')).to eq('en-CA')
      expect(klass.from_itc_to_standard('Brazilian Portuguese')).to eq('pt-BR')
    end

    it "returns nil when element can't be found" do
      expect(klass.from_itc_to_standard('asdfasdf')).to eq(nil)
    end
  end

  describe "#from_standard_to_itc" do
    it "works with valid inputs" do
      expect(klass.from_standard_to_itc('en-US')).to eq('English')
      expect(klass.from_standard_to_itc('pt-BR')).to eq('Brazilian Portuguese')
    end

    it "works with alternative values too" do
      expect(klass.from_standard_to_itc('de')).to eq('German')
    end

    it "returns nil when element can't be found" do
      expect(klass.from_standard_to_itc('asdfasdf')).to eq(nil)
    end
  end

  describe "from readable to value" do
    it "works with valid inputs" do
      expect(klass.from_itc_readable_to_itc('UK English')).to eq('English_UK')
    end

    it "returns nil when element doesn't exist" do
      expect(klass.from_itc_readable_to_itc('notHere')).to eq(nil)
    end
  end

  describe "from value to readable" do
    it "works with valid inputs" do
      expect(klass.from_itc_to_itc_readable('English_UK')).to eq('UK English')
    end

    it "returns nil when element doesn't exist" do
      expect(klass.from_itc_to_itc_readable('notHere')).to eq(nil)
    end
  end
end

describe String do
  describe "#to_itc_locale" do
    # verify all available itc primary languages match the right locale (itc variation)
    it "redirects to the actual converter" do
      expect("German".to_itc_locale).to eq("de-DE")
      expect("Traditional Chinese".to_itc_locale).to eq("zh-Hant")
      expect("Simplified Chinese".to_itc_locale).to eq("zh-Hans")
      expect("Danish".to_itc_locale).to eq("da")
      expect("Australian English".to_itc_locale).to eq("en-AU")
      expect("UK English".to_itc_locale).to eq("en-GB")
      expect("Canadian English".to_itc_locale).to eq("en-CA")
      expect("English".to_itc_locale).to eq("en-US")
      expect("Finnish".to_itc_locale).to eq("fin")
      expect("French".to_itc_locale).to eq("fr-FR")
      expect("Canadian French".to_itc_locale).to eq("fr-CA")
      expect("Greek".to_itc_locale).to eq("el")
      expect("Indonesian".to_itc_locale).to eq("id")
      expect("Italian".to_itc_locale).to eq("it")
      expect("Japanese".to_itc_locale).to eq("ja")
      expect("Korean".to_itc_locale).to eq("ko")
      expect("Malay".to_itc_locale).to eq("ms")
      expect("Dutch".to_itc_locale).to eq("nl-NL")
      expect("Norwegian".to_itc_locale).to eq("no")
      expect("Brazilian Portuguese".to_itc_locale).to eq("pt-BR")
      expect("Portuguese".to_itc_locale).to eq("pt-PT")
      expect("Russian".to_itc_locale).to eq("ru")
      expect("Swedish".to_itc_locale).to eq("sv")
      expect("Mexican Spanish".to_itc_locale).to eq("es-MX")
      expect("Spanish".to_itc_locale).to eq("es-ES")
      expect("Thai".to_itc_locale).to eq("th")
      expect("Turkish".to_itc_locale).to eq("tr")
      expect("Vietnamese".to_itc_locale).to eq("vi")
    end
  end

  describe "#to_language_code" do
    it "redirects to the actual converter" do
      expect("German".to_language_code).to eq("de-DE")
    end
  end

  describe "#to_full_language" do
    it "redirects to the actual converter" do
      expect("de".to_full_language).to eq("German")
    end
  end
end
