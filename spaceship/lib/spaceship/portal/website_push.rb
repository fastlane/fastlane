require_relative 'portal_base'

module Spaceship
  module Portal
    # Represents an Website Push ID from the Developer Portal
    class WebsitePush < PortalBase
      # @return (String) The identifier of this website push, provided by the Dev Portal
      # @example
      #   "RGAWZGXSAA"
      attr_accessor :website_id

      # @return (String) The name you provided for this website push
      # @example
      #   "Spaceship"
      attr_accessor :name

      # @return (String) the supported platform of this website push
      # @example
      #   "ios"
      attr_accessor :platform

      # Prefix provided by the Dev Portal
      # @example
      #   "5A997XSHK2"
      attr_accessor :prefix

      # @return (String) The bundle_id (website identifier) of website push id
      # @example
      #   "web.com.krausefx.app"
      attr_accessor :bundle_id

      # @return (String) Status of the website push
      # @example
      #   "current"
      attr_accessor :status

      attr_mapping(
        'websitePushId' => :website_id,
        'name' => :name,
        'prefix' => :prefix,
        'identifier' => :bundle_id,
        'status' => :status
      )

      alias app_id website_id # must be after attr_mapping

      class << self
        # @param mac [Bool] Fetches Mac website push if true
        # @return (Array) Returns all website push available for this account
        def all(mac: false)
          client.website_push(mac: mac).map { |website_push| self.new(website_push) }
        end

        # Creates a new Website Push ID on the Apple Dev Portal
        #
        # @param bundle_id [String] the bundle id (website_push_identifier) of the website push
        # @param name [String] the name of the Website Push
        # @param mac [Bool] is this a Mac Website Push?
        # @return (Website Push) The Website Push you just created
        def create!(bundle_id: nil, name: nil, mac: false)
          new_website_push = client.create_website_push!(name, bundle_id, mac: mac)
          self.new(new_website_push)
        end

        # Find a specific Website Push ID based on the bundle_id
        # @param mac [Bool] Searches Mac website pushes if true
        # @return (Website Push) The website push you're looking for. This is nil if the website push can't be found.
        def find(bundle_id, mac: false)
          all(mac: mac).find do |website_push|
            website_push.bundle_id == bundle_id
          end
        end
      end

      # Delete this Website Push ID.
      # @return (Website Push) The website you just deleted
      def delete!
        client.delete_website_push!(website_id, mac: mac?)
        self
      end

      # @return (Bool) Is this a Mac website push?
      def mac?
        platform == 'mac'
      end
    end
  end
end
