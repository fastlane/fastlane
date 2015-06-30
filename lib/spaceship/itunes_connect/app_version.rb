module Spaceship
  class AppVersion < TunesBase
    attr_accessor :application

    attr_accessor :version_id

    attr_accessor :copyright

    # @return (Bool) Is that the version that's currently available in the App Store?
    attr_accessor :is_live

    attr_mapping({
      'versionId' => :version_id,
      'copyright' => :copyright
    })

    class << self
      # Create a new object based on a hash.
      # This is used to create a new object based on the server response.
      def factory(attrs)
        orig = attrs.dup
        obj = self.new(attrs)
        obj.raw_data = orig

        obj
      end

      # @return (Array) Returns all apps available for this account
      # TODO: describe parameters
      def find(application, app_id, is_live = false)
        attrs = client.app_version(app_id, is_live)
        attrs.merge!(application: application)
        attrs.merge!(is_live: is_live)

        return self.factory(attrs)
      end
    end

    def is_live?
      is_live
    end

    # TODO: comment
    def save!
      client.update_app_version(application.apple_id, is_live?, raw_data)
    end
  end
end 