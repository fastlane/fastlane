
module Spaceship
  module Tunes
    class IAPFamilyDetails < TunesBase
      # @return (Spaceship::Tunes::Application) A reference to the application
      attr_accessor :application

      # @return (String) the family name
      attr_accessor :name

      # @return (Intger) the Family Id
      attr_accessor :family_id

      # @return (Hash) localized names
      attr_accessor :versions

      attr_mapping({
        'id' => :family_id,
        'name.value' => :name
      })

      class << self
        def factory(attrs)
          return self.new(attrs)
        end
      end

      def setup
        # Transform Localization versions to nice hash
        @versions = {}
        versions = raw_data["details"]["value"]
        versions.each do |version|
          language = version["value"]["localeCode"]["value"]
          @versions[language.to_sym] = {
            subscription_name: version["value"]["subscriptionName"]["value"],
            name: version["value"]["name"]["value"]
          }
        end
      end

      # modify existing family
      def save!
        # Transform localization versions back to original format.
        versions_array = []
        versions.each do |language_code, value|
          versions_array << {
                    value: {
                      subscriptionName: { value: value[:subscription_name] },
                      name: { value: value[:name] },
                      localeCode: { value: language_code.to_s }
                    }
          }
        end
        raw_data["details"]["value"] = versions_array
        client.update_iap_family!(app_id: application.apple_id, family_id: self.family_id, data: raw_data)
      end
    end
  end
end
