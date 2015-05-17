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
      'managingApp' => :managing_app
    })

    class << self
      def type
        raise "You cannot create a ProvisioningProfile without a type. Use a subclass."
      end

      def factory(attrs)

        attrs['distributionMethod'] = 'adhoc' if attrs['distributionMethod'] == 'store' && attrs['devices'].size > 0

        klass = case attrs['distributionMethod']
        when 'limited'
          Development
        when 'store'
          AppStore
        when 'adhoc'
          AdHoc
        else
          raise attrs['distributionMethod']
        end

        attrs['devices'].map! {|d| Device.new(d) }
        attrs['certificates'].map! {|c| Certificate.factory(c) }

        klass.new(attrs)
      end

      def create!(name: nil, bundle_id: nil, certificate: nil, devices: [])
        app = Spaceship::App.find(bundle_id)
        profile = client.create_provisioning_profile!(name, self.type, app.app_id, [certificate.id], devices.map{|d| d.id})
        self.new(profile)
      end

      def all
        profiles = client.provisioning_profiles.map do |profile|
          self.factory(profile)
        end

        return profiles if self == ProvisioningProfile

        #filter out the profiles that don't match the class.
        profiles.select do |profile|
          profile.class == self
        end
      end

      def find_by_bundle_id(bundle_id)
        all.find_all { |profile|
          profile.app.bundle_id == bundle_id
        }
      end

    end

    class Development < ProvisioningProfile
      def self.type
        'limited'
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

    def managed_by_xcode?
      managing_app == 'Xcode'
    end
  end
end
