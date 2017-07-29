
module Spaceship
  module Tunes
    class IAPFamilyList < TunesBase
      # @return (Spaceship::Tunes::Application) A reference to the application
      attr_accessor :application

      # @return (String) the family name
      attr_accessor :name

      # @return (Intger) the Family Id
      attr_accessor :family_id

      attr_mapping({
        'id' => :family_id,
        'name.value' => :name
      })

      class << self
        def factory(attrs)
          return self.new(attrs)
        end
      end

      # return a editable family object
      def edit
        attrs = client.load_iap_family(app_id: application.apple_id, family_id: self.family_id)
        attrs[:application] = application
        Tunes::IAPFamilyDetails.factory(attrs)
      end
    end
  end
end
