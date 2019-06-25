require_relative '../model'
module Spaceship
  class ConnectAPI
    class BetaGroup
      include Spaceship::ConnectAPI::Model

      attr_accessor :name
      attr_accessor :created_date
      attr_accessor :is_internal_group
      attr_accessor :public_link_enabled
      attr_accessor :public_link_id
      attr_accessor :public_link_limit_enabled
      attr_accessor :public_link_limit
      attr_accessor :public_link

      attr_mapping({
        "name" => "name",
        "createdDate" => "created_date",
        "isInternalGroup" => "is_internal_group",
        "publicLinkEnabled" => "public_link_enabled",
        "publicLinkId" => "public_link_id",
        "publicLinkLimitEnabled" => "public_link_limit_enabled",
        "publicLinkLimit" => "public_link_limit",
        "publicLink" => "public_link"
      })

      def self.type
        return "betaGroups"
      end

      #
      # API
      #

      # beta_testers - [{email: "", firstName: "", lastName: ""}]
      def post_bulk_beta_tester_assignments(beta_testers: nil)
        return Spaceship::ConnectAPI.post_bulk_beta_tester_assignments(beta_group_id: id, beta_testers: beta_testers)
      end
    end
  end
end
