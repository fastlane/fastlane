
module Spaceship
  module Tunes
    class IAPFamilies < TunesBase
      # @return (Spaceship::Tunes::Application) A reference to the application
      attr_accessor :application

      class << self
        def factory(attrs)
          return self.new(attrs)
        end
      end

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

      def create!(name: nil, product_id: nil, reference_name: nil, versions: [])
        client.create_iap_family(app_id: self.application.apple_id, name: name, product_id: product_id, reference_name: reference_name, versions: versions)
      end

      # returns a list of all families
      def all
        r = client.iap_families(app_id: self.application.apple_id)
        return_families = []
        r.each  do |i|
          attrs = i
          attrs[:application] = self.application
          loaded_family = Tunes::IAPFamilyList.factory(attrs)
          return_families << loaded_family
        end
        return_families
      end
    end
  end
end
