module Spaceship
  module Tunes
    class Tester < TunesBase

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

        # @return (String) The tester type used for web requests
        # @example
        #  "external"
        #  "internal"
        def type
          raise "You must select a tester type. Use a subclass."
        end

        # Create a new object based on a hash.
        # This is used to create a new object based on the server response.
        def factory(attrs)
          self.new(attrs)
        end

        # @return (Array) Returns all beta testers available for this account
        def all
          client.testers(self.type).map { |tester| self.factory(tester) }
        end

        # @return (Spaceship::Tunes::ExternalTester) Returns the external tester matching the parameter
        #   as either the Tester id or email
        def find(identifier)
          all.find do |tester|
            (tester.tester_id == identifier.to_s or tester.email == identifier)
          end
        end

        def create!(email: nil, first_name: nil, last_name: nil) 
          # NO RETORNA EL TESTER CREADO!
          data = client.create_tester!(type: self.type,
                               email: email,
                          first_name: first_name,
                           last_name: last_name)
          self.factory(data)
        end

        #####################################################
        # @!group App
        #####################################################
        def all_by_app(app_id) 
          client.testers_by_app(self.type, app_id).map { |tester| self.factory(tester) }
        end

        def find_by_app(app_id, identifier)
          all_by_app(app_id).find do |tester|
            (tester.tester_id == identifier.to_s or tester.email == identifier)
          end
        end
      end

      #####################################################
      # @!group Subclasses
      #####################################################
      class External < Tester 
        def self.type
          'external'
        end

        def type
          'external'
        end
      end

      #####################################################
      # @!group App
      #####################################################
      def add_to_app!(app_id)
        client.add_tester_to_app!(self.type, self, app_id)
      end

      def remove_from_app!(app_id)
        client.remove_tester_from_app!(self.type, self, app_id)
      end
    end
  end
end