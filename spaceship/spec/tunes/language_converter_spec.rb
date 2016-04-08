require 'spec_helper'

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
