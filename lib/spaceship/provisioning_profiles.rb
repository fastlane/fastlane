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
      #limited
    end

    class AppStore < Profile
      #store
    end

    class AdHoc < Profile
      #adhoc
    end

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

    def create(type, name, bundle_id, certificate, devices = nil)
      app = Spaceship.apps.find(bundle_id)
      profile = client.create_provisioning_profile(name, type, app.app_id, [certificate.id], devices)
      @profiles << self.class.factory(profile)
    end

    def file(bundle_id)
      profile = find_by_bundle_id(bundle_id)
      client.download_provisioning_profile(profile.id)
    end

    def find_by_bundle_id(bundle_id)
      @profiles.find do |profile|
        if profile.app.nil?
          app_attrs = client.provisioning_profile(profile.id)['appId']
          profile.app = Spaceship::Apps.factory(app_attrs)
        end

        profile.app.bundle_id == bundle_id
      end
    end
  end
end
