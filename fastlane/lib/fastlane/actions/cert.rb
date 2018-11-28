module Fastlane
  module Actions
    require 'fastlane/actions/get_certificates'
    class CertAction < GetCertificatesAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `get_certificates` action"
      end
    end
  end
end
