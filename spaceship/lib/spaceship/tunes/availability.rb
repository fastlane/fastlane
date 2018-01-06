require_relative 'territory'

module Spaceship
  module Tunes
    class Availability < TunesBase
      # @return (Bool) Are future territories included?
      attr_accessor :include_future_territories

      # @return (Array of Spaceship::Tunes::Territory objects) A list of the territories
      attr_accessor :territories

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
        return obj
      end

      def territories
        @territories ||= raw_data['countries'].map { |info| Territory.new(info) }
      end
    end
  end
end
