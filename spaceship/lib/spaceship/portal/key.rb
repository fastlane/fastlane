module Spaceship
  module Portal
    class Key < PortalBase
      ##
      # data model for managing JWT tokens or "Keys" as the ADP refers to them

      APNS_ID = 'U27F4V844T'
      DEVICE_CHECK_ID = 'DQ8HTZ7739'
      MUSIC_KIT_ID = '6A7HVUVQ3M'

      attr_accessor :id
      attr_accessor :name

      attr_mapping({
        'keyId' => :id,
        'keyName' => :name,
        'services' => :services,
        'canDownload' => :can_download,
        'canRevoke' => :can_revoke
      })

      def self.all
        keys = client.list_keys
        keys.map do |key|
          new(key)
        end
      end

      def self.find(id)
        keys = client.get_key(id: id)
        new(keys.first)
      end

      def self.create(name: nil, apns: nil, device_check: nil, music_kit: nil)
        service_ids = []
        service_ids << APNS_ID if apns
        service_ids << DEVICE_CHECK_ID if device_check
        service_ids << MUSIC_KIT_ID if music_kit

        keys = client.create_key!(name: name, service_ids: service_ids)
        # the response always contains an array of the newly created keys
        new(keys.first)
      end

      def revoke
        client.revoke_key!(id: id)
      end

      def download
        client.download_key(id: id)
      end

      def services
        # TODO[snatchev] lazy load services using client.get_key
        []
      end

      def has_apns?
        has_service?(APNS_ID)
      end

      def has_music_kit?
        has_service?(MUSIC_KIT_ID)
      end

      def has_device_check?
        has_service?(DEVICE_CHECK_ID)
      end

      private

      def has_service?(service_id)
        services.any? do |service|
          service['id'] == service_id
        end
      end
    end
  end
end
