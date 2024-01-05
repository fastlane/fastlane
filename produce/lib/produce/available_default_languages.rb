module Produce
  class AvailableDefaultLanguages
    # If you update this list, you probably also have to update these files:
    # - fastlane_core/lib/fastlane_core/languages.rb
    # - spaceship/lib/assets/languageMapping.json
    # See this pull request for example: https://github.com/fastlane/fastlane/pull/14110
    def self.all_languages
      [
        "Arabic",
        "Catalan",
        "Croatian",
        "Czech",
        "Brazilian Portuguese",
        "Danish",
        "Dutch",
        "English",
        "English_Australian",
        "English_CA",
        "English_UK",
        "Finnish",
        "French",
        "French_CA",
        "German",
        "Greek",
        "Hebrew",
        "Hindi",
        "Hungarian",
        "Indonesian",
        "Italian",
        "Japanese",
        "Korean",
        "Malay",
        "Norwegian",
        "Polish",
        "Portuguese",
        "Romanian",
        "Russian",
        "Simplified Chinese",
        "Slovak",
        "Spanish",
        "Spanish_MX",
        "Swedish",
        "Ukrainian",
        "Thai",
        "Traditional Chinese",
        "Turkish",
        "Vietnamese"
      ]
    end
  end
end
