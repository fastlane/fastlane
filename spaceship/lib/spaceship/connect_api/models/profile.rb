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

      attr_accessor :bundle_id
      attr_accessor :certificates

      attr_mapping({
        "name" => "name",
        "platform" => "platform",
        "profileContent" => "profile_content",
        "uuid" => "uuid",
        "createdDate" => "created_date",
        "profileState" => "profile_state",
        "profileType" => "profile_type",
        "expirationDate" => "expiration_date",

        "bundleId" => "bundle_id",
        "certificates" => "certificates",
        "devices" => "devices"
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
        MAC_CATALYST_APP_DEVELOPMENT = "MAC_CATALYST_APP_DEVELOPMENT"
        MAC_CATALYST_APP_STORE = "MAC_CATALYST_APP_STORE"
        MAC_CATALYST_APP_DIRECT = "MAC_CATALYST_APP_DIRECT"
      end

      def self.type
        return "profiles"
      end

      def valid?
        return profile_state == ProfileState::ACTIVE
      end

      #
      # API
      #

      def self.all(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_profiles(filter: filter, includes: includes).all_pages
        return resps.flat_map(&:to_models)
      end

      def self.create(client: nil, name: nil, profile_type: nil, bundle_id_id: nil, certificate_ids: nil, device_ids: nil, template_name: nil)
        client ||= Spaceship::ConnectAPI
        resp = client.post_profiles(
          bundle_id_id: bundle_id_id,
          certificates: certificate_ids,
          devices: device_ids,
          attributes: {
            name: name,
            profileType: profile_type,
            templateName: template_name
          }
        )
        return resp.to_models.first
      end

      def fetch_all_devices(client: nil, filter: {}, includes: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_devices(profile_id: id, filter: filter, includes: includes).all_pages
        return resps.flat_map(&:to_models)
      end

      def fetch_all_certificates(client: nil, filter: {}, includes: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_certificates(profile_id: id, filter: filter, includes: includes).all_pages
        return resps.flat_map(&:to_models)
      end

      def delete!(client: nil)
        client ||= Spaceship::ConnectAPI
        return client.delete_profile(profile_id: id)
      end
    end
  end
end
