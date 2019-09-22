require_relative 'tunes_base'

module Spaceship
  module Tunes
    class IAPFamilyDetails < TunesBase
      # @return (Spaceship::Tunes::Application) A reference to the application
      attr_accessor :application

      # @return (String) the family name
      attr_accessor :name

      # @return (Intger) the family id
      attr_accessor :family_id

      # @return (Array) all linked in-app purchases of this family
      attr_accessor :linked_iaps

      # @return (Intger) amount of linked in-app purchases of this family (read-only)
      attr_accessor :iap_count

      attr_mapping({
        'id' => :family_id,
        'name.value' => :name,
        'activeAddOns' => :linked_iaps,
        'totalActiveAddOns' => :iap_count
      })

      def versions=(value = {})
        if value.kind_of?(Array)
          # input that comes from iTC api
          return
        end
        new_versions = []
        value.each do |language, current_version|
          new_versions << {
            "value" =>   {
              "subscriptionName" =>  { "value" => current_version[:subscription_name] },
              "name" =>  { "value" => current_version[:name] },
              "localeCode" => { "value" => language }
            }
          }
        end

        raw_data.set(["details"], { "value" => new_versions })
      end

      # @return (Hash) localized names
      def versions
        parsed_versions = {}
        raw_versions = raw_data["details"]["value"]
        raw_versions.each do |version|
          language = version["value"]["localeCode"]["value"]
          parsed_versions[language.to_sym] = {
            subscription_name: version["value"]["subscriptionName"]["value"],
            name: version["value"]["name"]["value"]
          }
        end
        return parsed_versions
      end

      # modify existing family
      def save!
        # Transform localization versions back to original format.
        versions_array = []
        versions.each do |language_code, value|
          versions_array << {
                               "value" => {
                                 "subscriptionName" => { "value" => value[:subscription_name] },
                                 "name" => { "value" => value[:name] },
                                 "localeCode" => { "value" => language_code.to_s }
                               }
                            }
        end

        raw_data.set(["details"], { "value" => versions_array })

        client.update_iap_family!(app_id: application.apple_id, family_id: self.family_id, data: raw_data)
      end
    end
  end
end
