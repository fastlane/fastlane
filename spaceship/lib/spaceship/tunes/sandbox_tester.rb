require_relative 'tunes_base'

module Spaceship
  module Tunes
    class SandboxTester < TunesBase
      # @return (String) The email of this sandbox tester
      # @example
      #   "tester@spaceship.com"
      attr_accessor :email

      # @return (String) The first name of this tester
      # @example
      #   "Cary"
      attr_accessor :first_name

      # @return (String) The last name of this tester
      # @example
      #   "Bennett"
      attr_accessor :last_name

      # @return (String) The two-letter country code of this tester
      # @example
      #   "US"
      attr_accessor :country

      attr_mapping(
        'emailAddress.value' => :email,
        'firstName.value' => :first_name,
        'lastName.value' => :last_name,
        'storeFront.value' => :country
      )

      def self.url
        {
          index:  "ra/users/iap",
          create: "ra/users/iap/add",
          delete: "ra/users/iap/delete"
        }
      end

      def self.all
        client.sandbox_testers(self).map { |tester| self.new(tester) }
      end

      def self.create!(email: nil, password: nil, first_name: 'Test', last_name: 'Test', country: 'US')
        data = client.create_sandbox_tester!(
          tester_class: self,
          email: email,
          password: password,
          first_name: first_name,
          last_name: last_name,
          country: country
        )
        self.new(data)
      end

      def self.delete!(emails)
        client.delete_sandbox_testers!(self, emails)
      end

      def self.delete_all!
        delete!(self.all.map(&:email))
      end

      #####################################################
      # @!group Subclasses
      #####################################################
      # Delete current tester
      def delete!
        client.delete_tester!(self)
      end
    end
  end
end
