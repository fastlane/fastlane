require 'spec_helper'

describe Spaceship::Tunes::LanguageItem do
  before do
    Spaceship::Tunes.login
  end

  describe "#inspect" do
    it "prints out all languages with their values" do
      str = Spaceship::Application.all.first.edit_version.name.inspect
      expect(str).to eq("German: yep, that's the name\nEnglish: App Name 123\n")
    end
  end
end