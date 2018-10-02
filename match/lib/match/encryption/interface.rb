module Match
  module Encryption
    class Interface
      # Returns the class to be used for a given `storage_mode`
      def self.encryption_class_for_storage_mode(storage_mode)
        if storage_mode == "git"
          require_relative './openssl'
          return Encryption::OpenSSL
        elsif storage_mode == "google_cloud"
          # return Encryption::GoogleCloudKMS
        else
          UI.user_error!("Invalid storage mode '#{storage_mode}'")
        end
      end

      # Call this method to trigger the actual
      # encryption
      def encrypt_files
        not_implemented(__method__)
      end

      # Call this method to trigger the actual
      # decryption
      def decrypt_files
        not_implemented(__method__)
      end
    end
  end
end
