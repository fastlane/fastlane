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
        'theWorld' => :include_future_territories
      )

      # Create a new object based on a set of territories.
      # @param territories (Array of String or Spaceship::Tunes::Territory objects): A list of the territories
      # @param params (Hash): Optional parameters (include_future_territories (Bool, default: true) Are future territories included?)
      def self.from_territories(territories = [], params = {})
        obj = self.new
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
        return @territories unless @territories.nil?
        @territories ||= raw_data['countries'].map { |info| Territory.new(info) }
      end

      def cleared_for_preorder
        return @cleared_for_preorder unless @cleared_for_preorder.nil?

        value = false
        if (pre_order = raw_data['preOrder']) && (hash = pre_order['clearedForPreOrder'])
          value = hash['value']
        end
        @cleared_for_preorder ||= value
      end

      def app_available_date
        return @app_available_date unless @app_available_date.nil?

        if (pre_order = raw_data['preOrder']) && (hash = pre_order['appAvailableDate'])
          value = hash['value']
        end
        @app_available_date ||= value
      end
    end
  end
end
