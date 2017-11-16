module Fastlane
  module Actions
    require 'fastlane/actions/renew_push_certificate'
    class PemAction < RenewPushCertificateAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `renew_push_certificate` action"
      end
    end
  end
end
