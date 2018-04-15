require_relative 'territory'

module Spaceship
  module Tunes
    class Availability < TunesBase
      # @return (Bool) Are future territories included?
      attr_accessor :include_future_territories

      # @return (Array of Spaceship::Tunes::Territory objects) A list of the territories
      attr_accessor :territories

      # @return (Bool) Cleared for preorder
      attr_accessor :cleared_for_preorder

      # @return (String) App available date in format of "YYYY-MM-DD"
      attr_accessor :app_available_date

      attr_mapping(
        'theWorld' => :include_future_territories,
        'preOrder.clearedForPreOrder.value' => :cleared_for_preorder,
        'preOrder.appAvailableDate.value' => :app_available_date
      )

      # Create a new object based on a set of territories.
      # @param territories (Array of String or Spaceship::Tunes::Territory objects): A list of the territories
      # @param params (Hash): Optional parameters (include_future_territories (Bool, default: true) Are future territories included?)
      def self.from_territories(territories = [], params = {})
        # Initializes the DataHash with our preOrder structure so values
        # that are being modified will be saved
        #
        # Note: A better solution for this in the future might be to improve how
        # Base::DataHash sets values for paths that don't exist
        obj = self.new(
          'preOrder' => {
            'clearedForPreOrder' => {
              'value' => false
            },
            'appAvailableDate' => {
              'value' => nil
            }
          }
        )

        # Detect if the territories attribute is an array of Strings and convert to Territories
        obj.territories =
          if territories[0].kind_of?(String)
            territories.map { |territory| Spaceship::Tunes::Territory.from_code(territory) }
          else
            territories
          end
        obj.include_future_territories = params.fetch(:include_future_territories, true)
        obj.cleared_for_preorder = params.fetch(:cleared_for_preorder, false)
        obj.app_available_date = params.fetch(:app_available_date, nil)
        return obj
      end

      def territories
        @territories ||= raw_data['countries'].map { |info| Territory.new(info) }
      end

      def cleared_for_preorder
        super || false
      end
    end
  end
end
