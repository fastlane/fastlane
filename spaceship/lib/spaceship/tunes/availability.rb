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

      # @return (Bool) app enabled for educational discount
      attr_accessor :educational_discount

      # @return (Bool) b2b available for distribution
      attr_accessor :b2b_unavailable

      # @return (Array of Spaceship::Tunes::B2bUser objects) A list of users
      attr_accessor :b2b_users

      attr_mapping(
        'theWorld' => :include_future_territories,
        'preOrder.clearedForPreOrder.value' => :cleared_for_preorder,
        'preOrder.appAvailableDate.value' => :app_available_date,
        'b2BAppFlagDisabled' => :b2b_unavailable
      )

      # Create a new object based on a set of territories.
      # This will override any values already set for cleared_for_preorder, app_available_date, b2b_unavailable,
      # b2b_app_enabled, and educational_discount
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
        obj.educational_discount = params.fetch(:educational_discount, true)
        return obj
      end

      def territories
        @territories ||= raw_data['countries'].map { |info| Territory.new(info) }
      end

      def b2b_users
        @b2b_users || raw_data['b2bUsers'].map { |user| B2bUser.new(user) }
      end

      def b2b_app_enabled
        @b2b_app_enabled.nil? ? raw_data['b2bAppEnabled'] : @b2b_app_enabled
      end

      def educational_discount
        @educational_discount.nil? ? raw_data['educationalDiscount'] : @educational_discount
      end

      def cleared_for_preorder
        super || false
      end

      # Sets `b2b_app_enabled` to true and `educational_discount` to false
      # Requires users to be added with `add_b2b_users` otherwise `update_availability` will error
      def enable_b2b_app!
        raise "Not possible to enable b2b on this app" if b2b_unavailable
        @b2b_app_enabled = true
        # need to set the educational discount to false
        @educational_discount = false
        return self
      end

      # Adds users for b2b enabled apps
      def add_b2b_users(user_list = [])
        raise "Cannot add b2b users if b2b is not enabled" unless b2b_app_enabled
        @b2b_users = user_list.map { |user| B2bUser.from_username(user) }
        return self
      end

      # Updates users for b2b enabled apps
      def update_b2b_users(user_list = [])
        raise "Cannot add b2b users if b2b is not enabled" unless b2b_app_enabled

        added_users = b2b_users.map(&:ds_username)

        # Returns if list is unchanged
        return self if (added_users - user_list) == (user_list - added_users)

        users_to_add = user_list.reject { |user| added_users.include?(user) }
        users_to_remove = added_users.reject { |user| user_list.include?(user) }

        @b2b_users = b2b_users.reject { |user| users_to_remove.include?(user.ds_username) }
        @b2b_users.concat(users_to_add.map { |user| B2bUser.from_username(user) })
        @b2b_users.concat(users_to_remove.map { |user| B2bUser.from_username(user, is_add_type: false) })

        return self
      end
    end
  end
end
