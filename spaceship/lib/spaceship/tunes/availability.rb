require_relative 'territory'
require_relative 'b2b_user'

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

      # @return (Bool) app enabled for b2b users
      attr_accessor :b2b_app_enabled

      # @return (Bool) b2b available for distribution
      attr_accessor :b2b_unavailable

      attr_accessor :b2b_users

      attr_mapping(
        'theWorld' => :include_future_territories,
        'preOrder.clearedForPreOrder.value' => :cleared_for_preorder,
        'preOrder.appAvailableDate.value' => :app_available_date,
        'b2bAppEnabled' => :b2b_app_enabled,
        'b2BAppFlagDisabled' => :b2b_unavailable
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
        obj.b2b_unavailable =  params.fetch(:b2b_unavailable, false)
        obj.b2b_app_enabled =  params.fetch(:b2b_app_enabled, false)
        return obj
      end

      def territories
        @territories ||= raw_data['countries'].map { |info| Territory.new(info) }
      end

      def b2b_users
        @b2b_users ||= raw_data['b2bUsers'].map { |user| B2bUser.new(user) }
      end

      def cleared_for_preorder
        super || false
      end

      # Sets the b2b flag. If you call Save on app_details without adding any b2b users
      # it will result in an error.
      def enable_b2b_app!
        print("b2b : " + b2b_unavailable.to_s)
        raise "Not possible to enable b2b on this app" if b2b_unavailable
        @b2b_app_enabled = true
        return self
      end

      # just adds to the availability, You will still have to call update_availabilty
      def add_b2b_users(user_list = [])
        raise "Cannot add b2b users if b2b is not enabled" unless b2b_app_enabled
        b2b_user_array = []
        user_list.each do |user|
          b2b_user_array.push(B2bUser.from_username(user))
        end
        @b2b_users = b2b_user_array
        return self
      end
    end
  end
end
