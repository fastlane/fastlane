module Spaceship
  class ProvisioningProfile < Base

    attr_accessor :id, :uuid, :expires, :distribution_method, :name, :status, :type, :version, :platform, :managing_app, :app, :certificates, :devices

    attr_mapping({
      'provisioningProfileId' => :id,
      'UUID' => :uuid,
      'dateExpire' => :expires,
      'distributionMethod' => :distribution_method,
      'name' => :name,
      'status' => :status,
      'type' => :type,
      'version' => :version,
      'proProPlatform' => :platform,
      'managingApp' => :managing_app,
      'appId' => :app
    })

    class << self
      def type
        raise "You cannot create a ProvisioningProfile without a type. Use a subclass."
      end

      def factory(attrs)
        # Ad Hoc Profiles look exactly like App Store profiles, but usually include devices
        attrs['distributionMethod'] = 'adhoc' if attrs['distributionMethod'] == 'store' && attrs['devices'].size > 0
        # available values of `distributionMethod` at this point: ['adhoc', 'store', 'limited']

        klass = case attrs['distributionMethod']
        when 'limited'
          Development
        when 'store'
          AppStore
        when 'adhoc'
          AdHoc
        else
          raise "Can't find class '#{attrs['distributionMethod']}'"
        end

        attrs['appId'] = App.factory(attrs['appId'])
        attrs['devices'].map! { |device| Device.factory(device) }
        attrs['certificates'].map! { |cert| Certificate.factory(cert) }

        klass.new(attrs)
      end

      # @param name (String) The name of the provisioning profile on the Dev Portal
      # @param bundle_id (String) The app identifier, this paramter is required
      # TODO: complete
      def create!(name: nil, bundle_id: nil, certificate: nil, devices: [])
        raise "Missing required parameter 'bundle_id'" if bundle_id.to_s.empty?
        raise "Missing required parameter 'certificate'. e.g. use `Spaceship::Certificate::Production.all.first`" if certificate.to_s.empty?

        app = Spaceship::App.find(bundle_id)

        # Fill in sensible default values
        name ||= [bundle_id, self.pretty_type].join(' ')
        devices = Spaceship.devices if (devices.nil? or devices.count == 0) # all devices by default

        profile = client.create_provisioning_profile!(name, 
                                              self.type, 
                                              app.app_id, 
                                              [certificate.id], 
                                              devices.map {|d| d.id} )
        self.new(profile)
      end

      def all
        profiles = client.provisioning_profiles.map do |profile|
          self.factory(profile)
        end

        # filter out the profiles managed by xcode
        profiles.delete_if do |profile|
          profile.managed_by_xcode?
        end

        return profiles if self == ProvisioningProfile

        # only return the profiles that match the class
        profiles.select do |profile|
          profile.class == self
        end
      end

      def find_by_bundle_id(bundle_id)
        all.find_all do |profile|
          profile.app.bundle_id == bundle_id
        end
      end

    end

    class Development < ProvisioningProfile
      def self.type
        'limited'
      end

      def self.pretty_type
        return 'development'.capitalize
      end
    end

    class AppStore < ProvisioningProfile
      def self.type
        'store'
      end
    end

    class AdHoc < ProvisioningProfile
      def self.type
        'adhoc'
      end
    end

    def download
      client.download_provisioning_profile(self.id)
    end

    def delete!
      client.delete_provisioning_profile!(self.id)
    end

    def self.pretty_type
      type.capitalize
    end

    def managed_by_xcode?
      managing_app == 'Xcode'
    end
  end
end
