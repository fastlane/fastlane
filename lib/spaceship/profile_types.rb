module Spaceship
  # This class contains the codes used for the different types of profiles
  class Client
    class ProfileTypes
      class SigningCertificate
        def self.development
          "5QPB9NHCEI"
        end
        def self.distribution
          "R58UK2EWSO"
        end
      end

      class Push
        def self.development
          "BKLRAVXMGM"
        end
        def self.production
          "3BQKVH9I2X"
        end
      end

      def self.all_profile_types
        [
          "5QPB9NHCEI", # Development Code Signing Identity
          "R58UK2EWSO", # Distribution Code Signing Identity
          "9RQEK7MSXA", # iOS Distribution certificate signing request
          "LA30L5BJEU", # MDM CSR certificate signing request
          "BKLRAVXMGM", # Development Push Certificates
          "3BQKVH9I2X", # Production Push Certificates
          "Y3B2F3TYSI", # Pass Type ID pass certificate request
          "3T2ZP62QW8", # Website Push Id
          "E5D663CMZW", # Website Push Id
          "4APLUP237T"  # Apple Pay
        ]
      end
    end
  end
end