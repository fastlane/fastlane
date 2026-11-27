require_relative '../model'
module Spaceship
  class ConnectAPI
    class Actor
      include Spaceship::ConnectAPI::Model

      attr_accessor :actor_type
      attr_accessor :user_first_name
      attr_accessor :user_last_name
      attr_accessor :user_email
      attr_accessor :api_key_id

      attr_mapping({
        actorType: 'actor_type',
        userFirstName: 'user_first_name',
        userLastName: 'user_last_name',
        userEmail: 'user_email',
        apiKeyId: 'api_key_id'
      })

      def self.type
        return 'actors'
      end
    end
  end
end
