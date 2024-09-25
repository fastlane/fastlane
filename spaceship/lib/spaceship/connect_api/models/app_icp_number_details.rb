require_relative '../model'

module Spaceship
	class ConnectAPI
		class AppIcpNumberDetail
			include Spaceship::ConnectAPI::Model

			attr_accessor :icp_number
			attr_accessor :verification_status
			attr_accessor :developer_name_mismatch_consent

			module VerificationStatus
				DEV_NAME_MISMATCH = "DEV_NAME_MISMATCH"
				VERIFIED = "VERIFIED"
			end

			attr_mapping({
        "icpNumber" => "icp_number",
        "verificationStatus" => "verification_status",
        "developerNameMismatchConsent" => "developer_name_mismatch_consent",
      })

			def self.type
				return "appIcpNumberDetails"
			end
		end
	end
end