module Spaceship
  module Tunes
    class Tester < TunesBase

      # @return (String) The identifier of this tester, provided by iTunes Connect
      # @example 
      #   "60f858b4-60a8-428a-963a-f943a3d68d17"
      attr_accessor :tester_id

      # @return (String) The email of this tester
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

        # @return (Spaceship::Tunes::Tester) Returns the tester matching the parameter
        #   as either the Tester id or email
        # @param identifier (String) (required): Value used to filter the tester
        def find(identifier)
          all.find do |tester|
            (tester.tester_id == identifier.to_s or tester.email == identifier)
          end
        end

        # Create new tester in iTunes Connect
        # @param email (String) (required): The email of the new tester
        # @param first_name (String) (optional): The first name of the new tester
        # @param last_name (String) (optional): The last name of the new tester
        # @example 
        #   Spaceship::Tunes::Tester.external.create!(email: "tester@mathiascarignani.com", first_name: "Cary", last_name:"Bennett")
        # @return (Tester): The newly created tester
        def create!(email: nil, first_name: nil, last_name: nil) 
          data = client.create_tester!(type: self.type,
                               email: email,
                          first_name: first_name,
                           last_name: last_name)
          self.factory(data)
        end

        #####################################################
        # @!group App
        #####################################################

        # @return (Array) Returns all beta testers available for this account filtered by app
        # @param app_id (String) (required): The app id to filter the testers
        def all_by_app(app_id) 
          client.testers_by_app(self.type, app_id).map { |tester| self.factory(tester) }
        end

        # @return (Spaceship::Tunes::Tester) Returns the tester matching the parameter
        #   as either the Tester id or email
        # @param app_id (String) (required): The app id to filter the testers
        # @param identifier (String) (required): Value used to filter the tester
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

      # Add current tester to list of the app testers
      # @param app_id (String) (required): The id of the application to which want to modify the list
      def add_to_app!(app_id)
        client.add_tester_to_app!(self.type, self, app_id)
      end

      # Remove current tester from list of the app testers
      # @param app_id (String) (required): The id of the application to which want to modify the list
      def remove_from_app!(app_id)
        client.remove_tester_from_app!(self.type, self, app_id)
      end
    end
  end
end