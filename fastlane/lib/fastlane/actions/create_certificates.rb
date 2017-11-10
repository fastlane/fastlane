module Fastlane
  module Actions
    require 'fastlane/actions/cert'
    class CreateCertificatesAction < CertAction

      def self.run(config)
        UI.message "Creating signing certificates using cert"
        super.run(config)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Create new iOS code signing certificates (via cert)"
      end
    end
  end
end
