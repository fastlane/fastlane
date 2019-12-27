require_relative '../model'
module Spaceship
  class ConnectAPI
    class BuildBetaDetail
      include Spaceship::ConnectAPI::Model

      attr_accessor :auto_notify_enabled
      attr_accessor :did_notify
      attr_accessor :internal_build_state
      attr_accessor :external_build_state

      module InternalState
        PROCESSING = "PROCESSING"
        PROCESSING_EXCEPTION = "PROCESSING_EXCEPTION"
        MISSING_EXPORT_COMPLIANCE = "MISSING_EXPORT_COMPLIANCE"
        READY_FOR_BETA_TESTING = "READY_FOR_BETA_TESTING"
        IN_BETA_TESTING = "IN_BETA_TESTING"
        EXPIRED = "EXPIRED"
        IN_EXPORT_COMPLIANCE_REVIEW = "IN_EXPORT_COMPLIANCE_REVIEW"
      end

      module ExternalState
        PROCESSING = "PROCESSING"
        PROCESSING_EXCEPTION = "PROCESSING_EXCEPTION"
        MISSING_EXPORT_COMPLIANCE = "MISSING_EXPORT_COMPLIANCE"
        READY_FOR_BETA_TESTING = "READY_FOR_BETA_TESTING"
        IN_BETA_TESTING = "IN_BETA_TESTING"
        EXPIRED = "EXPIRED"
        READY_FOR_BETA_SUBMISSION = "READY_FOR_BETA_SUBMISSION"
        IN_EXPORT_COMPLIANCE_REVIEW = "IN_EXPORT_COMPLIANCE_REVIEW"
        WAITING_FOR_BETA_REVIEW = "WAITING_FOR_BETA_REVIEW"
        IN_BETA_REVIEW = "IN_BETA_REVIEW"
        BETA_REJECTED = "BETA_REJECTED"
        BETA_APPROVED = "BETA_APPROVED"
      end

      attr_mapping({
        "autoNotifyEnabled" => "auto_notify_enabled",
        "didNotify" => "did_notify",
        "internalBuildState" => "internal_build_state",
        "externalBuildState" => "external_build_state"
      })

      def self.type
        return "buildBetaDetails"
      end

      #
      # Helpers
      #
      #
      def ready_for_internal_testing?
        return internal_build_state == InternalState::READY_FOR_BETA_TESTING
      end

      def ready_for_beta_submission?
        return external_build_state == ExternalState::READY_FOR_BETA_SUBMISSION
      end
    end
  end
end
