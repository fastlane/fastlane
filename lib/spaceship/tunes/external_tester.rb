module Spaceship
  module Tunes
    class ExternalTester < TunesBase

      attr_accessor :tester_id

      attr_accessor :email
      
      attr_accessor :first_name

      attr_accessor :last_name

      attr_mapping(
        'testerId' => :tester_id,
        'emailAddress.value' => :email,
        'firstName.value' => :first_name,
        'lastName.value' => :last_name
      )

      class << self
        # Create a new object based on a hash.
        # This is used to create a new object based on the server response.
        def factory(attrs)
          self.new(attrs)
        end

        # @return (Array) Returns all beta testers available for this account
        def all
          client.external_testers.map { |external_tester| self.factory(external_tester) }
        end

        # @return (Spaceship::Tunes::ExternalTester) Returns the external tester matching the parameter
        #   as either the Tester id or email
        def find(identifier)
          all.find do |external_tester|
            (external_tester.tester_id == identifier.to_s or external_tester.email == identifier)
          end
        end

        def create!(email: nil, first_name: nil, last_name: nil) 
          client.create_external_tester!(email: email,
                                    first_name: first_name,
                                     last_name: last_name)
        end
      end
    end
  end
end