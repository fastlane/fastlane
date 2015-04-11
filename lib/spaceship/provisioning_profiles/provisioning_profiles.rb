require 'spaceship/provisioning_profiles/download_provisioning_profile'
require 'spaceship/provisioning_profiles/generate_provisioning_profile'

module Spaceship
  class ProvisioningProfile < Struct.new(:client, :name, :type, :app_id, :app, :status, :expiration, :uuid, :id, :is_xcode_managed, :distribution_method, :devices)
    # Parse the server response
    def self.create(client, hash)
      prov = ProvisioningProfile.new(
        client,
        hash['name'],
        hash['type'],
        hash['appId']['appIdId'],
        App.create(hash['appId']), # All information related to the app
        hash['status'],
        hash['dateExpire'],
        hash['UUID'],
        hash['provisioningProfileId'],
        hash['managingApp'] == 'Xcode',
        hash['distributionMethod'], # Available values: limited, adhoc, store
        hash['devices'].collect { |d| Device.create(client, d) }
      )

      # Apple stores AdHoc profiles as 'store'. We want to be able to also select adhoc profiles
      # Since ad hoc profiles usually contain devices (otherwise they are useless), we can set that based on this
      prov.distribution_method = 'adhoc' if (prov.distribution_method == 'store' and prov.devices.count > 0)

      prov
    end

    # Downloads the given provisioning profile
    def download
      client.download_provisioning_profile(self)
    end

    def generate!
      client.generate_provisioning_profile!(self, self.distribution_method)
    end

    def to_s
      [self.name, self.type, self.app_id].join(" - ")
    end

    # Example

    # name="net.sunapps.7 AppStore",
    # type="iOS Distribution",
    # app_id="572XTN75U2",
    # app=
    #   #<struct Spaceship::App
    #   app_id="572XTN75U2",
    #   name="App Name",
    #   platform="ios",
    #   prefix="5A997XSHK2",
    #   identifier="net.sunapps.7",
    #   is_wildcard=false,
    #   dev_push_enabled=false,
    #   prod_push_enabled=false>,
    # status="Active",
    # expiration=#<DateTime: 2015-11-25T22:45:50+00:00>,
    # uuid="aad7df3b-9767-4e85-a1ea-1df4d8f32faa",
    # id="2MAY7NPHRU",
    # is_xcode_managed=false,
    # distribution_method="store">
  end



  class Client
    def provisioning_profiles
      return @provisioning_profiles if @provisioning_profiles

      response = unzip(Excon.post(URL_LIST_PROVISIONING_PROFILES, 
        headers: { 'Cookie' => "myacinfo=#{@myacinfo}" },
        body: "teamId=#{@team_id}"))
      profiles = Plist::parse_xml(response)['provisioningProfiles']
      
      @provisioning_profiles = profiles.collect do |current|
        if current['managingApp'] != 'Xcode' # we don't want to deal with those profiles
          ProvisioningProfile.create(self, current)
        end
      end.delete_if { |a| a.nil? } # since we ignore the Xcode ones
    end

    # Looks for a certain provisioning profile
    # If it doesn't exist yet, it will be created
    # @param distribution_method valid values: [store, limited, adhoc]
    def fetch_provisioning_profile(bundle_identifier, distribution_method)
      raise "Invalid distribution_method '#{distribution_method}'".red unless ['store', 'adhoc', 'limited'].include?distribution_method

      provisioning_profiles.each do |profile|
        if profile.app.identifier == bundle_identifier and profile.distribution_method == distribution_method
          return profile
        end
      end

      Helper.log.warn "Profile doesn't exist yet... creating it now"
      profile = ProvisioningProfile.new
      profile.client = self
      profile.distribution_method = distribution_method
      profile.name = (Sigh.config[:provisioning_name] || [bundle_identifier, distribution_method].join(' '))
      profile.app = fetch_app(bundle_identifier)
      profile.generate!

      @provisioning_profiles = nil # to fetch them again, since we changed something

      if Helper.is_test? # to not end in an endless recursion
        bundle_identifier = 'net.sunapps.9'
        distribution_method = 'store'
      end
      
      fetch_provisioning_profile(bundle_identifier, distribution_method) # such recursive
    end
  end
end
