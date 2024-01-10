require 'base64'
require 'openssl'
require 'securerandom'

module Match
  module Encryption
    # This is to keep backwards compatibility with the old fastlane version which used the local openssl installation.
    # The encryption parameters in this implementation reflect the old behavior which was the most common default value in those versions.
    # As for decryption, 1.0.x OpenSSL and earlier versions use MD5, 1.1.0c and newer uses SHA256, we try both before giving an error
    class EncryptionV1
      ALGORITHM = 'aes-256-cbc'

      def encrypt(data, password, salt, hash_algorithm = "MD5")
        cipher = ::OpenSSL::Cipher.new(ALGORITHM)
        cipher.encrypt

        keyivgen(cipher, password, salt, hash_algorithm)

        encrypted_data = cipher.update(data)
        encrypted_data << cipher.final
      end
      def decrypt(encrypted_data, password, salt, hash_algorithm = "MD5")
        cipher = ::OpenSSL::Cipher.new(ALGORITHM)
        cipher.decrypt

        keyivgen(cipher, password, salt, hash_algorithm)

        data = cipher.update(encrypted_data)
        data << cipher.final
      end

      private

      def keyivgen(cipher, password, salt, hash_algorithm)
        cipher.pkcs5_keyivgen(password, salt, 1, hash_algorithm)
      end
    end

    # The newer encryption mechanism
    # A more secure key and IV generation
    # IV is randomly generated and provided unencrypted
    # salt should be randomly generated and provided unencrypted (like in the current implementation)
    # key is generated with OpenSSL::KDF::pbkdf2_hmac with properly chosen parameters
    # Short explanation about salt and IV: https://stackoverflow.com/a/1950674/6324550
    class EncryptionV2
      ALGORITHM = 'AES-256-GCM'

      def encrypt(data, password, salt)
        cipher = ::OpenSSL::Cipher.new(ALGORITHM)
        cipher.encrypt

        keyivgen(cipher, password, salt)

        encrypted_data = cipher.update(data)
        encrypted_data << cipher.final

        auth_tag = cipher.auth_tag

        { encrypted_data: encrypted_data, auth_tag: auth_tag }
      end

      def decrypt(encrypted_data, password, salt, auth_tag)
        cipher = ::OpenSSL::Cipher.new(ALGORITHM)
        cipher.decrypt

        keyivgen(cipher, password, salt)

        cipher.auth_tag = auth_tag

        data = cipher.update(encrypted_data)
        data << cipher.final
      end

      private

      def keyivgen(cipher, password, salt)
        keyIv = ::OpenSSL::KDF.pbkdf2_hmac(password, salt: salt, iterations: 10_000, length: 32 + 12 + 24, hash: "sha256")
        key = keyIv[0..31]
        iv = keyIv[32..43]
        auth_data = keyIv[44..-1]
        cipher.key = key
        cipher.iv = iv
        cipher.auth_data = auth_data
      end
    end

    class MatchDataEncryption
      V1_PREFIX = "Salted__"
      V2_PREFIX = "2_Salted__"

      def encrypt(data, password, version = 2)
        salt = SecureRandom.random_bytes(8)
        if version == 2
          e = EncryptionV2.new
          encryption = e.encrypt(data, password, salt)
          encrypted_data = V2_PREFIX + salt + encryption[:auth_tag] + encryption[:encrypted_data]
        else
          e = EncryptionV1.new
          encrypted_data = V1_PREFIX + salt + e.encrypt(data, password, salt)
        end
        Base64.encode64(encrypted_data)
      end

      # expected_salt is only used when testing
      def decrypt(base64encoded_encrypted, password)
        stored_data = Base64.decode64(base64encoded_encrypted)
        if stored_data.start_with?(V2_PREFIX)
          salt = stored_data[10..17]
          auth_tag = stored_data[18..33]
          data_to_decrypt = stored_data[34..-1]
          e = EncryptionV2.new
          e.decrypt(data_to_decrypt, password, salt, auth_tag)
        else
          salt = stored_data[8..15]
          data_to_decrypt = stored_data[16..-1]
          e = EncryptionV1.new
          begin
            e.decrypt(data_to_decrypt, password, salt)
          rescue => _ex
            # Note that we are not guaranteed to catch the decryption errors here if the password is wrong
            # as there's no integrity checks.
            # With a wrong password, there's a 0.4% chance it will decrypt garbage and not fail
            fallback_hash_algorithm = "SHA256"
            e.decrypt(data_to_decrypt, password, salt, fallback_hash_algorithm)
          end
        end
      end
    end

    # by default, encrypt or decrypt in place
    class MatchFileEncryption
      def encrypt(file_path, password, output_path = nil)
        output_path = file_path unless output_path
        data_to_encrypt = File.binread(file_path)
        e = MatchDataEncryption.new
        data = e.encrypt(data_to_encrypt, password)
        File.write(output_path, data)
      end
      def decrypt(file_path, password, output_path = nil)
        output_path = file_path unless output_path
        content = File.read(file_path)
        e = MatchDataEncryption.new
        decrypted_data = e.decrypt(content, password)
        File.binwrite(output_path, decrypted_data)
      end
    end
  end
end
