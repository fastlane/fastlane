module Match
  module Encryption
    class Interface
      # Call this method to trigger the actual
      # encryption
      def encrypt_files(password: nil)
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
