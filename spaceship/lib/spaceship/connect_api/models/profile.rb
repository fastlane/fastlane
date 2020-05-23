require_relative '../model'
module Spaceship
  class ConnectAPI
    class Profile
      include Spaceship::ConnectAPI::Model

      attr_accessor :name
      attr_accessor :platform
      attr_accessor :profile_content
      attr_accessor :uuid
      attr_accessor :created_date
      attr_accessor :profile_state
      attr_accessor :profile_type
      attr_accessor :expiration_date

      attr_mapping({
        "name" => "name",
        "platform" => "platform",
        "profileContent" => "profile_content",
        "uuid" => "uuid",
        "createdDate" => "created_date",
        "profileState" => "profile_state",
        "profileType" => "profile_type",
        "expirationDate" => "expiration_date"
      })

      module ProfileState
        ACTIVE = "ACTIVE"
        INVALID = "INVALID"
      end

      module ProfileType
        IOS_APP_DEVELOPMENT = "IOS_APP_DEVELOPMENT"
        IOS_APP_STORE = "IOS_APP_STORE"
        IOS_APP_ADHOC = "IOS_APP_ADHOC"
        IOS_APP_INHOUSE = "IOS_APP_INHOUSE"
        MAC_APP_DEVELOPMENT = "MAC_APP_DEVELOPMENT"
        MAC_APP_STORE = "MAC_APP_STORE"
        MAC_APP_DIRECT = "MAC_APP_DIRECT"
        TVOS_APP_DEVELOPMENT = "TVOS_APP_DEVELOPMENT"
        TVOS_APP_STORE = "TVOS_APP_STORE"
        TVOS_APP_ADHOC = "TVOS_APP_ADHOC"
        TVOS_APP_INHOUSE = "TVOS_APP_INHOUSE"
      end

      def self.type
        return "profiles"
      end

      #
      # API
      #

      def self.all(filter: {}, includes: nil, limit: nil, sort: nil)
        resps = Spaceship::ConnectAPI.get_profiles(filter: filter, includes: includes).all_pages
        return resps.flat_map(&:to_models)
      end
    end
  end
end
