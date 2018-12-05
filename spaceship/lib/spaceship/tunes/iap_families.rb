require_relative 'iap_family_list'

module Spaceship
  module Tunes
    class IAPFamilies < TunesBase
      # @return (Spaceship::Tunes::Application) A reference to the application
      attr_accessor :application

      # Create a new Purchase Family
      # a freshly created family has to have atleast one product.
      # the product will be created, and versions/pricing_intervals and so on
      # should be set by subsequent edit.
      # @param name (String) Familyname
      # @param product_id (String) New Product's id
      # @param reference_name (String) Reference name of the new product
      # @param versions (Hash) Localized Familie names
      # @example
      #  versions: {
      #  'de-DE': {
      #    subscription_name: "Subname German",
      #    name: 'App Name German',
      #  },
      #  'da': {
      #    subscription_name: "Subname DA",
      #    name: 'App Name DA',
      #  }
      # }

      def create!(name: nil, product_id: nil, reference_name: nil, versions: {})
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
        client.create_iap_family(app_id: self.application.apple_id, name: name, product_id: product_id, reference_name: reference_name, versions: versions_array)
      end

      # returns a list of all families
      def all
        r = client.iap_families(app_id: self.application.apple_id)
        return_families = []
        r.each do |family|
          attrs = family
          attrs[:application] = self.application
          loaded_family = Tunes::IAPFamilyList.factory(attrs)
          return_families << loaded_family
        end
        return_families
      end
    end
  end
end
