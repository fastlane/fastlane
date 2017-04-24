module Spaceship::TestFlight
  class Tester < Base
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

    # @return (Array) an array of associated groups
    # @example
    #    [{
    #      "id": "e031e048-4f0f-4c1e-8d8a-a5341a267986",
    #      "name": {
    #        "value": "My App Testers"
    #      }
    #    }]
    attr_accessor :groups

    # @return (Array) An array of registered devices for this user
    # @example
    #    [{
    #      "model": "iPhone 6",
    #      "os": "iOS",
    #      "osVersion": "8.3",
    #      "name": null
    #    }]

    # Information about the most recent beta install
    # @return [Integer] The ID of the most recently installed app
    attr_accessor :app_id

    attr_mapping(
      'id' => :tester_id,
      'email' => :email,
      'firstName' => :first_name,
      'lastName' => :last_name,
      'groups' => :groups,
      'appAdamId' => :app_id,
    )

    # @return (Array) Returns all beta testers available for this account
    def self.all(app_id: nil)
      client.testers_for_app(app_id: app_id).map { |data| self.new(data) }
    end

    # @return (Spaceship::Tunes::Tester) Returns the tester matching the parameter
    #   as either the Tester id or email
    # @param identifier (String) (required): Value used to filter the tester, case insensitive
    def self.find(app_id: nil, email: nil)
      self.all(app_id: app_id).find { |tester| tester.email == email }
    end

    #####################################################
    # @!group App
    #####################################################

    # Add current tester to list of the app testers
    # @param app_id (String) (required): The id of the application to which want to modify the list
    def add_to_app!(app_id: nil)

    end

    # Remove current tester from list of the app testers
    # @param app_id (String) (required): The id of the application to which want to modify the list
    def remove_from_app!(app_id: nil)
      client.delete_tester_from_app(app_id: app_id, tester: self)
    end
  end
end
