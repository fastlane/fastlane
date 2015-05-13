module Spaceship
  class ProvisioningProfiles
    include Enumerable
    extend Forwardable

    attr_reader :client
    def_delegators :@profiles, :each, :first, :last

    class Profile < Struct.new(:id, :uuid, :expires, :distribution_method, :name, :status, :type, :version, :platform, :managing_app, :app)
      def managed_by_xcode?
        managing_app == 'Xcode'
      end
    end

    class Development < Profile
      def self.type
        'limited'
      end
    end

    class AppStore < Profile
      def self.type
        'store'
      end
    end

    class AdHoc < Profile
      def self.type
        'adhoc'
      end
    end

    ##
    # Helper method for instantiating structs from API responses
    # @params attrs [Hash] attributes returned from API to be mapped onto a struct
    #
    # @return [Spaceship::ProvisioningProfiles::Profile] subclass of Profile that matches the distribution method of the profile
    def self.factory(attrs)
      values = attrs.values_at('provisioningProfileId', 'UUID', 'dateExpire', 'distributionMethod', 'name', 'status', 'type', 'version', 'proProPlatfrom')
      method = attrs['distributionMethod']
      klass = case method
      when 'store'
        AppStore
      when 'adhoc'
        AdHoc
      when 'limited'
        Development
      else
        puts "Unknown distributionMethod: `#{method}`"
        Profile
      end
      klass.new(*values)
    end

    def initialize(client)
      @client = client
      @profiles = client.provisioning_profiles.map do |profile|
        self.class.factory(profile)
      end
    end

    ##
    # Creates a new provisioning profile
    #
    # @param klass [Spaceship::ProvisioningProfiles::Profile] the class of the profile to create. Must be a `Development`, `AppStore`, or `AdHoc`
    # @param name [String] the name of the provisioning profile
    # @param bundle_id [String] the bundle id of the app associated with this provisioning profile
    # @param certificate [Spaceship::Certificates::Certificate] an instance of a certificate used for the provisioning profile. Either `Production` or `Development`
    #
    # @return [Spaceship::ProvisioningProfiles::Profile] the newly created provisioning profile
    def create(klass, name, bundle_id, certificate, devices = nil)
      app = Spaceship.apps.find(bundle_id)
      profile = client.create_provisioning_profile(name, klass.type, app.app_id, [certificate.id], devices)
      @profiles << self.class.factory(profile)
    end

    ##
    # download the provisioning profile associated with a bundle_id
    #
    # @param bundle_id [String] the bundle_id of the app associated with the provisioning profile
    #
    # @return [String] the contents of the provisioning profile
    def download(bundle_id)
      profile = find_by_bundle_id(bundle_id)
      client.download_provisioning_profile(profile.id)
    end

    ##
    # Helper method to find a provisioning profile that matches a bundle_id of the associated app
    def find_by_bundle_id(bundle_id)
      @profiles.find_all do |profile|
        if profile.app.nil?
          app_attrs = client.provisioning_profile(profile.id)['appId']
          profile.app = Spaceship::Apps.factory(app_attrs)
        end

        profile.app.bundle_id == bundle_id
      end
    end
  end
end
