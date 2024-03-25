require_relative '../model'
module Spaceship
  class ConnectAPI
    class BetaAppTesterDetail
      include Spaceship::ConnectAPI::Model

      attr_accessor :max_internal_testers
      attr_accessor :max_external_testers
      attr_accessor :max_internal_groups
      attr_accessor :max_external_groups
      attr_accessor :current_internal_testers
      attr_accessor :current_external_testers
      attr_accessor :currentDeletedTesters

      attr_mapping({
        "maxInternalTesters" => "max_internal_testers",
        "maxExternalTesters" => "max_external_testers",
        "maxInternalGroups" => "max_internal_groups",
        "maxExternalGroups" => "max_external_groups",
        "currentInternalTesters" => "current_internal_testers",
        "currentExternalTesters" => "current_external_testers",
        "currentDeletedTesters" => "current_deleted_testers",
      })

      def self.type
        return "betaAppTesterDetails"
      end
    end
  end
end
