module Deliver
  module Languages
    # 2020-08-24 - Available locales are not available as an endpoint in App Store Connect
    # Update with Spaceship::Tunes.client.available_languages.sort (as long as endpoint is available)
    ALL_LANGUAGES = %w[ar-SA ca cs da de-DE el en-AU en-CA en-GB en-US es-ES es-MX fi fr-CA fr-FR he hi hr hu id it ja ko ms nl-NL no pl pt-BR pt-PT ro ru sk sv th tr uk vi zh-Hans zh-Hant]
  end
end
