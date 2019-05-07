require_relative './model'
module Spaceship
  module ConnectAPI
    class BuildBetaDetail
      include Spaceship::ConnectAPI::Model

      attr_accessor :auto_notify_enabled
      attr_accessor :did_notify
      attr_accessor :internal_build_state
      attr_accessor :external_build_state

      attr_mapping({
        "autoNotifyEnabled" => "auto_notify_enabled",
        "didNotify" => "did_notify",
        "internalBuildState" => "internal_build_state",
        "externalBuildState" => "external_build_state"
      })

      def self.type
        return "buildBetaDetails"
      end
    end
  end
end
