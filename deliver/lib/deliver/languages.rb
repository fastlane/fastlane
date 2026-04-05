module Deliver
  module Languages
    # 2020-08-24 - Available locales are not available as an endpoint in App Store Connect
    # Update with Spaceship::Tunes.client.available_languages.sort (as long as endpoint is available)
    ALL_LANGUAGES = %w[ar-SA bn ca cs da de-DE el en-AU en-CA en-GB en-US es-ES es-MX fi fr-CA fr-FR gu he hi hr hu id it ja kn ko ml mr ms nl-NL no or pa pl pt-BR pt-PT ro ru sk sl sv ta te th tr uk ur vi zh-Hans zh-Hant]
  end
end
