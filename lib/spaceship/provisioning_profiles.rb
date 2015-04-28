module Spaceship
  class ProvisioningProfiles
    include Spaceship::SharedClient
    include Enumerable
    extend Forwardable

    def_delegators :@provisioning_profiles, :each, :first, :last

=begin
UUID: "0f3175bc-c164-4590-98f1-b25aabe419b1"
certificateIds: []
dateExpire: "2016-04-23"
deviceIds: []
distributionMethod: "limited"
managingApp: "Xcode"
name: "iOSTeam Provisioning Profile: *"
proProPlatform: "ios"
provisioningProfileId: "F2KD22T6NP"
status: "Active"
type: "iOS Development"
version: "2"
=end

    Profile = Struct.new(:id, :uuid, :expires, :distribution_method, :name, :status, :type, :version, :platform)

    def initialize
      @profiles = client.provisioning_profiles.map do |profile|
        values = profile.values_at('provisioningProfileId', 'UUID', 'dateExpire', 'distributionMethod', 'name', 'status', 'type', 'version', 'proProPlatfrom')
        Profile.new(*values)
      end
    end

    def create(params = {})
    end

    def file(profile_id)
      file = client.download_provisioning_profile(profile_id)
    end
  end
end
