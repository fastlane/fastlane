require_relative 'tunes_base'

module Spaceship
  module Tunes
    class IAPFamilyDetails < TunesBase
      # @return (Spaceship::Tunes::Application) A reference to the application
      attr_accessor :application

      # @return (String) the family name
      attr_accessor :name

      # @return (Integer) the family id
      attr_accessor :family_id

      # @return (Array) all linked in-app purchases of this family
      attr_accessor :linked_iaps

      # @return (Integer) amount of linked in-app purchases of this family (read-only)
      attr_accessor :iap_count

      # @return (Array) of all in-app purchase family details
      attr_accessor :family_details

      attr_mapping({
        'id' => :family_id,
        'name.value' => :name,
        'activeAddOns' => :linked_iaps,
        'totalActiveAddOns' => :iap_count,
        'details.value' => :family_details
      })

      # @return (Hash) localized names
      def versions
        parsed_versions = {}
        raw_versions = raw_data["details"]["value"]
        raw_versions.each do |version|
          language = version["value"]["localeCode"]["value"]
          parsed_versions[language.to_sym] = {
            subscription_name: version["value"]["subscriptionName"]["value"],
            name: version["value"]["name"]["value"],
            id: version["value"]["id"],
            status: version["value"]["status"]
          }
        end
        return parsed_versions
      end

      # transforms user-set versions to iTC ones
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
              "localeCode" => { "value" => language },
              "id" => current_version[:id]
            }
          }
        end

        raw_data.set(["details"], { "value" => new_versions })
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
                                 "localeCode" => { "value" => language_code.to_s },
                                 "id" => value[:id]
                               }
                            }
        end

        raw_data.set(["details"], { "value" => versions_array })

        client.update_iap_family!(app_id: application.apple_id, family_id: self.family_id, data: raw_data)
      end
    end
  end
end
