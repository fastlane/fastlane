require_relative '../model'
module Spaceship
  class ConnectAPI
    class BetaTester
      include Spaceship::ConnectAPI::Model

      attr_accessor :first_name
      attr_accessor :last_name
      attr_accessor :email
      attr_accessor :invite_type
      attr_accessor :invitation

      attr_accessor :apps
      attr_accessor :beta_groups
      attr_accessor :beta_tester_metrics
      attr_accessor :builds

      attr_mapping({
        "firstName" => "first_name",
        "lastName" => "last_name",
        "email" => "email",
        "inviteType" => "invite_type",
        "invitation" => "invitation",

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
