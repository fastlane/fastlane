module Fastlane
  module Actions
    require 'fastlane/actions/create_certificates'
    class CertAction < CreateCertificatesAction
      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Alias for the `create_certificates` action"
      end
    end
  end
end
