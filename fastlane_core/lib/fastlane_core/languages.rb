module FastlaneCore
  module Languages
    # These are all the languages which are available to use to upload app metadata and screenshots

    # The old format which was used until August 2015 (good old times)
    ALL_LANGUAGES_LEGACY = %w[da-DK de-DE el-GR en-AU en-CA en-GB en-US es-ES es-MX fi-FI fr-CA fr-FR id-ID it-IT ja-JP ko-KR ms-MY nl-NL no-NO pt-BR pt-PT ru-RU sv-SE th-TH tr-TR vi-VI cmn-Hans cmn-Hant]

    # The new format used from September 2015 on
    # This was generated from `Spaceship::Tunes.client.available_languages.sort`
    # Updates should also be made to:
    # - produce/lib/produce/available_default_languages.rb
    # - spaceship/lib/assets/languageMapping.json
    # See pull request for example: https://github.com/fastlane/fastlane/pull/14110
    ALL_LANGUAGES = %w[ar-SA ca cs da de-DE el en-AU en-CA en-GB en-US es-ES es-MX fi fr-CA fr-FR he hi hr hu id it ja ko ms nl-NL no pl pt-BR pt-PT ro ru sk sv th tr uk vi zh-Hans zh-Hant]
  end
end
