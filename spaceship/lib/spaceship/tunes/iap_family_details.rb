
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
        versions.each do |v|
          language = v["value"]["localeCode"]["value"]
          @versions[language.to_sym] = {
            subscription_name: v["value"]["subscriptionName"]["value"],
            name: v["value"]["name"]["value"]
          }
        end
      end

      # modify existing family
      def save!
        # Transform localization versions back to original format.
        versions_array = []
        versions.each do |k, v|
          versions_array << {
                    value: {
                      subscriptionName: { value: v[:subscription_name] },
                      name: { value: v[:name] },
                      localeCode: { value: k.to_s }
                    }
          }
        end
        raw_data["details"]["value"] = versions_array
        client.update_iap_family!(app_id: application.apple_id, family_id: self.family_id, data: raw_data)
      end
    end
  end
end
