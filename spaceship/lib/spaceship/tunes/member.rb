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
      attr_accessor :has_all_apps
      attr_accessor :not_accepted_invitation
      attr_accessor :user_id

      attr_mapping(
        'emailAddress.value' => :email_address,
        'firstName.value' => :firstname,
        'lastName.value' => :lastname,
        'userName' => :username,
        'dsId' => :user_id
      )

      class << self
        def factory(attrs)
          self.new(attrs)
        end
      end

      def setup
        @selected_apps = []
        if raw_data["userSoftwares"]["value"]["grantAllSoftware"]
          @has_all_apps = true
        else
          raw_data["userSoftwares"]["value"]["grantedSoftwareAdamIds"].each do |app_id|
            @selected_apps << Application.find(app_id)
          end
        end

        if raw_data["activationExpiry"]
          @not_accepted_invitation = true
        end

        currency_base = raw_data["preferredCurrency"]["value"]
        @preferred_currency = {
          name:    currency_base["name"],
          code:    currency_base["currencyCode"],
          country: currency_base["countryName"],
          country_code: currency_base["countryCode"]
        }

        @roles = []
        raw_data["roles"].each do |role|
          @roles << role["value"]["name"]
        end
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
