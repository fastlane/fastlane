require_relative 'tunes_base'
require_relative 'application'

module Spaceship
  module Tunes
    class Member < TunesBase
      attr_accessor :email_address
      attr_accessor :firstname
      attr_accessor :lastname
      attr_accessor :username
      attr_accessor :not_accepted_invitation
      attr_accessor :user_id

      attr_mapping(
        'emailAddress.value' => :email_address,
        'firstName.value' => :firstname,
        'lastName.value' => :lastname,
        'userName' => :username,
        'dsId' => :user_id
      )

      ROLES = {
        admin: 'admin',
        app_manager: 'appmanager',
        sales: 'sales',
        developer: 'developer',
        marketing: 'marketing',
        reports: 'reports'
      }

      def roles
        parsed_roles = []
        raw_data["roles"].each do |role|
          parsed_roles << role["value"]["name"]
        end
        return parsed_roles
      end

      def admin?
        roles.include?(ROLES[:admin])
      end

      def app_manager?
        roles.include?(ROLES[:app_manager])
      end

      def preferred_currency
        currency_base = raw_data["preferredCurrency"]["value"]
        return {
          name:    currency_base["name"],
          code:    currency_base["currencyCode"],
          country: currency_base["countryName"],
          country_code: currency_base["countryCode"]
        }
      end

      def selected_apps
        parsed_apps = []
        raw_data["userSoftwares"]["value"]["grantedSoftwareAdamIds"].each do |app_id|
          parsed_apps << Application.find(app_id)
        end
        return parsed_apps
      end

      def not_accepted_invitation
        return true if raw_data["activationExpiry"]
        return false
      end

      def has_all_apps
        selected_apps.length == 0
      end

      def delete!
        client.delete_member!(self.user_id, self.email_address)
      end

      def resend_invitation
        client.reinvite_member(self.email_address)
      end
    end
  end
end
