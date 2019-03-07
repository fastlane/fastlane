require 'base64'
require 'openssl'
require 'securerandom'
require 'security'
require 'shellwords'

require_relative '../change_password'
require_relative '../module'

module Match
  module Encryption
    class OpenSSL < Interface
      attr_accessor :keychain_name

      attr_accessor :working_directory

      def self.configure(params)
        return self.new(
          keychain_name: params[:keychain_name],
          working_directory: params[:working_directory]
        )
      end

      # @param keychain_name: The identifier used to store the passphrase in the Keychain
      # @param working_directory: The path to where the certificates are stored
      def initialize(keychain_name: nil, working_directory: nil)
        self.keychain_name = keychain_name
        self.working_directory = working_directory
      end

      def encrypt_files
        files = []
        iterate(self.working_directory) do |current|
          files << current
          encrypt_specific_file(path: current, password: password)
          UI.success("🔒  Encrypted '#{File.basename(current)}'") if FastlaneCore::Globals.verbose?
        end
        UI.success("🔒  Successfully encrypted certificates repo")
        return files
      end

      def decrypt_files
        files = []
        iterate(self.working_directory) do |current|
          files << current
          begin
            decrypt_specific_file(path: current, password: password)
          rescue => ex
            UI.verbose(ex.to_s)
            UI.error("Couldn't decrypt the repo, please make sure you enter the right password!")
            UI.user_error!("Invalid password passed via 'MATCH_PASSWORD'") if ENV["MATCH_PASSWORD"]
            clear_password
            self.decrypt_files # call itself
            return
          end
          UI.success("🔓  Decrypted '#{File.basename(current)}'") if FastlaneCore::Globals.verbose?
        end
        UI.success("🔓  Successfully decrypted certificates repo")
        return files
      end

      def store_password(password)
        Security::InternetPassword.add(server_name(self.keychain_name), "", password)
      end

      # removes the password from the keychain again
      def clear_password
        Security::InternetPassword.delete(server: server_name(self.keychain_name))
      end

      private

      def iterate(source_path)
        Dir[File.join(source_path, "**", "*.{cer,p12,mobileprovision}")].each do |path|
          next if File.directory?(path)
          yield(path)
        end
      end

      # server name used for accessing the macOS keychain
      def server_name(keychain_name)
        ["match", keychain_name].join("_")
      end

      # Access the MATCH_PASSWORD, either from ENV variable, Keychain or user input
      def password
        password = ENV["MATCH_PASSWORD"]
        unless password
          item = Security::InternetPassword.find(server: server_name(self.keychain_name))
          password = item.password if item
        end

        unless password
          if !UI.interactive?
            UI.error("Neither the MATCH_PASSWORD environment variable nor the local keychain contained a password.")
            UI.error("Bailing out instead of asking for a password, since this is non-interactive mode.")
            UI.user_error!("Try setting the MATCH_PASSWORD environment variable, or temporarily enable interactive mode to store a password.")
          else
            UI.important("Enter the passphrase that should be used to encrypt/decrypt your certificates")
            UI.important("This passphrase is specific per repository and will be stored in your local keychain")
            UI.important("Make sure to remember the password, as you'll need it when you run match on a different machine")
            password = ChangePassword.ask_password(confirm: true)
            store_password(password)
          end
        end

        return password
      end

      # We encrypt with MD5 because that was the most common default value in older fastlane versions which used the local OpenSSL installation
      # A more secure key and IV generation is needed in the future
      # IV should be randomly generated and provided unencrypted
      # salt should be randomly generated and provided unencrypted (like in the current implementation)
      # key should be generated with OpenSSL::KDF::pbkdf2_hmac with properly chosen parameters
      # Short explanation about salt and IV: https://stackoverflow.com/a/1950674/6324550
      def encrypt_specific_file(path: nil, password: nil)
        UI.user_error!("No password supplied") if password.to_s.strip.length == 0

        data_to_encrypt = File.binread(path)
        salt = SecureRandom.random_bytes(8)

        # The :: is important, as there is a name clash
        cipher = ::OpenSSL::Cipher.new('AES-256-CBC')
        cipher.encrypt
        cipher.pkcs5_keyivgen(password, salt, 1, "MD5")
        encrypted_data = "Salted__" + salt + cipher.update(data_to_encrypt) + cipher.final

        File.write(path, Base64.encode64(encrypted_data))
      rescue FastlaneCore::Interface::FastlaneError
        raise
      rescue => error
        UI.error(error.to_s)
        UI.crash!("Error encrypting '#{path}'")
      end

      # The encryption parameters in this implementations reflect the old behaviour which depended on the users' local OpenSSL version
      # 1.0.x OpenSSL and earlier versions use MD5, 1.1.0c and newer uses SHA256, we try both before giving an error
      def decrypt_specific_file(path: nil, password: nil, hash_algorithm: "MD5")
        stored_data = Base64.decode64(File.read(path))
        salt = stored_data[8..15]
        data_to_decrypt = stored_data[16..-1]

        decipher = ::OpenSSL::Cipher.new('AES-256-CBC')
        decipher.decrypt
        decipher.pkcs5_keyivgen(password, salt, 1, hash_algorithm)

        decrypted_data = decipher.update(data_to_decrypt) + decipher.final

        File.binwrite(path, decrypted_data)
      rescue => error
        fallback_hash_algorithm = "SHA256"
        if hash_algorithm != fallback_hash_algorithm
          decrypt_specific_file(path: path, password: password, hash_algorithm: fallback_hash_algorithm)
        else
          UI.error(error.to_s)
          UI.crash!("Error decrypting '#{path}'")
        end
      end
    end
  end
end
