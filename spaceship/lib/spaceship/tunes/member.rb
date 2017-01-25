module Spaceship
  module Tunes
    class Member < TunesBase
      attr_accessor :email_address
      attr_accessor :firstname
      attr_accessor :lastname
      attr_accessor :preferred_currency
      attr_accessor :roles
      attr_accessor :username
      attr_accessor :selected_apps
      attr_accessor :not_accepted_invitation
      attr_accessor :user_id

      attr_mapping(
        'emailAddress.value' => :email_address,
        'firstName.value' => :firstname,
        'lastName.value' => :lastname,
        'userName' => :username,
        'dsId' => :user_id,
        'preferredCurrency' => :preferred_currency,
        'userSoftwares' => :selected_apps,
        'roles' => :roles
      )

      class << self
        def factory(attrs)
          parsed_apps = []

          attrs["userSoftwares"]["value"]["grantedSoftwareAdamIds"].each do |app_id|
            parsed_apps << Application.find(app_id)
          end
          attrs["userSoftwares"] = parsed_apps

          currency_base = attrs["preferredCurrency"]["value"]
          attrs["preferredCurrency"] = {
            name:    currency_base["name"],
            code:    currency_base["currencyCode"],
            country: currency_base["countryName"],
            country_code: currency_base["countryCode"]
          }

          parsed_roles = []
          attrs["roles"].each do |role|
            parsed_roles << role["value"]["name"]
          end

          attrs["roles"] = parsed_roles
          self.new(attrs)
        end
      end

      def not_accepted_invitation
        return true if raw_data["activationExpiry"]
        return false
      end

      def has_all_apps
        raw_data["userSoftwares"].length == 0
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
