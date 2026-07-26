require_relative '../model'
module Spaceship
  class ConnectAPI
    class BetaTester
      include Spaceship::ConnectAPI::Model

      attr_accessor :first_name
      attr_accessor :last_name
      attr_accessor :email
      attr_accessor :invite_type
      attr_accessor :beta_tester_state
      attr_accessor :is_deleted
      attr_accessor :last_modified_date
      attr_accessor :installed_cf_bundle_short_version_string
      attr_accessor :installed_cf_bundle_version
      attr_accessor :remove_after_date
      attr_accessor :installed_device
      attr_accessor :installed_os_version
      attr_accessor :number_of_installed_devices
      attr_accessor :latest_expiring_cf_bundle_short_version_string
      attr_accessor :latest_expiring_cf_bundle_version_string
      attr_accessor :installed_device_platform
      attr_accessor :latest_installed_device
      attr_accessor :latest_installed_os_version
      attr_accessor :latest_installed_device_platform

      attr_accessor :apps
      attr_accessor :beta_groups
      attr_accessor :beta_tester_metrics
      attr_accessor :builds

      attr_mapping({
        "firstName" => "first_name",
        "lastName" => "last_name",
        "email" => "email",
        "inviteType" => "invite_type",
        "betaTesterState" => "beta_tester_state",
        "isDeleted" => "is_deleted",
        "lastModifiedDate" => "last_modified_date",
        "installedCfBundleShortVersionString" => "installed_cf_bundle_short_version_string",
        "installedCfBundleVersion" => "installed_cf_bundle_version",
        "removeAfterDate" => "remove_after_date",
        "installedDevice" => "installed_device",
        "installedOsVersion" => "installed_os_version",
        "numberOfInstalledDevices" => "number_of_installed_devices",
        "latestExpiringCfBundleShortVersionString" => "latest_expiring_cf_bundle_short_version_string",
        "latestExpiringCfBundleVersionString" => "latest_expiring_cf_bundle_version_string",
        "installedDevicePlatform" => "installed_device_platform",
        "latestInstalledDevice" => "latest_installed_device",
        "latestInstalledOsVersion" => "latest_installed_os_version",
        "latestInstalledDevicePlatform" => "latest_installed_device_platform",

        "apps" => "apps",
        "betaGroups" => "beta_groups",
        "betaTesterMetrics" => "beta_tester_metrics",
        "builds" => "builds"
      })

      def self.type
        return "betaTesters"
      end

      #
      # API
      #

      def self.all(client: nil, filter: {}, includes: nil, limit: nil, sort: nil)
        client ||= Spaceship::ConnectAPI
        resps = client.get_beta_testers(filter: filter, includes: includes).all_pages
        return resps.flat_map(&:to_models)
      end

      def self.find(client: nil, email: nil, includes: nil)
        client ||= Spaceship::ConnectAPI
        return all(client: client, filter: { email: email }, includes: includes).first
      end

      def delete_from_apps(client: nil, apps: nil)
        client ||= Spaceship::ConnectAPI
        app_ids = apps.map(&:id)
        return client.delete_beta_tester_from_apps(beta_tester_id: id, app_ids: app_ids)
      end

      def delete_from_beta_groups(client: nil, beta_groups: nil)
        client ||= Spaceship::ConnectAPI
        beta_group_ids = beta_groups.map(&:id)
        return client.delete_beta_tester_from_beta_groups(beta_tester_id: id, beta_group_ids: beta_group_ids)
      end
    end
  end
end
