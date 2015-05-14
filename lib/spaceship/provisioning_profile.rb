module Spaceship
  class ProvisioningProfile < Base

    attr_accessor :id, :uuid, :expires, :distribution_method, :name, :status, :type, :version, :platform, :managing_app, :app

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
      def create(type: nil, name: nil, bundle_id: nil, certificate: nil, devices: nil)
        app = Spaceship.apps.find(bundle_id)
        profile = client.create_provisioning_profile(name, type.type, app.app_id, [certificate.id], devices.map{|d| d.id})
        self.new(profile)
      end

      def all
        client.provisioning_profiles.map do |profile|
          self.new(profile)
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

    def app
      @app ||= Spaceship::App.new(client.provisioning_profile(profile.id)['appId'])
    end

    def managed_by_xcode?
      managing_app == 'Xcode'
    end
  end
end
