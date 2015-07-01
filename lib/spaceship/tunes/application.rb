module Spaceship
  module Tunes
    class Application < TunesBase
      
      # @return (String) The App identifier of this app, provided by iTunes Connect
      # @example 
      #   "1013943394"
      attr_accessor :apple_id

      # @return (String) The name you provided for this app (in the default language)
      # @example
      #   "Spaceship App"
      attr_accessor :name

      # @return (String) the supported platform of this app
      # @example 
      #   "ios"
      attr_accessor :platform

      # @return (String) The Vendor ID provided by iTunes Connect
      # @example 
      #   "1435592086"
      attr_accessor :vendor_id

      # @return (String) The bundle_id (app identifier) of your app
      # @example 
      #   "com.krausefx.app"
      attr_accessor :bundle_id

      # @return (String) Last modified
      attr_accessor :last_modified

      # @return (Integer) The number of issues provided by iTunes Connect
      attr_accessor :issues_count

      # @return (String) The URL to a low resolution app icon of this app (340x340px). Might be nil
      # @example 
      #   "https://is1-ssl.mzstatic.com/image/thumb/Purple7/v4/cd/a3/e2/cda3e2ac-4034-c6af-ee0c-3e4d9a0bafaa/pr_source.png/340x340bb-80.png"
      # @example
      #   nil
      attr_accessor :app_icon_preview_url

      attr_mapping(
        'adamId' => :apple_id,
        'name' => :name,
        'appType' => :platform,
        'vendorId' => :vendor_id,
        'bundleId' => :bundle_id,
        'lastModifiedDate' => :last_modified,
        'issuesCount' => :issues_count,
        'iconUrl' => :app_icon_preview_url
      )

      class << self
        # Create a new object based on a hash.
        # This is used to create a new object based on the server response.
        def factory(attrs)
          self.new(attrs)
        end

        # @return (Array) Returns all apps available for this account
        def all
          client.applications.map { |application| self.factory(application) }
        end
      end

      def live_version
        v = Spaceship::AppVersion.find(self, self.apple_id, true)
      end

      def edit_version
        Spaceship::AppVersion.find(self, self.apple_id, false)
      end
    end
  end
end
