module Spaceship
  class ProvisioningProfiles
    include Enumerable
    extend Forwardable

    attr_reader :client
    def_delegators :@provisioning_profiles, :each, :first, :last

    class Profile < Struct.new(:id, :uuid, :expires, :distribution_method, :name, :status, :type, :version, :platform, :managing_app)
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

    def initialize(client)
      @client = client
      @profiles = client.provisioning_profiles.map do |profile|
        values = profile.values_at('provisioningProfileId', 'UUID', 'dateExpire', 'distributionMethod', 'name', 'status', 'type', 'version', 'proProPlatfrom')
        Profile.new(*values)
      end
    end

    def create(type, name, app_id, certificates, devices)

    end

    def file(profile_id)
      client.download_provisioning_profile(profile_id)
    end
  end
end
