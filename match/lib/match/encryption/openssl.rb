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

      attr_accessor :force_legacy_encryption

      def self.configure(params)
        return self.new(
          keychain_name: params[:keychain_name],
          working_directory: params[:working_directory],
          force_legacy_encryption: params[:force_legacy_encryption]
        )
      end

      # @param keychain_name: The identifier used to store the passphrase in the Keychain
      # @param working_directory: The path to where the certificates are stored
      # @param force_legacy_encryption: Force use of legacy EncryptionV1 algorithm
      def initialize(keychain_name: nil, working_directory: nil, force_legacy_encryption: false)
        self.keychain_name = keychain_name
        self.working_directory = working_directory
        self.force_legacy_encryption = force_legacy_encryption
      end

      def encrypt_files(password: nil)
        files = []
        password ||= fetch_password!
        iterate(self.working_directory) do |current|
          files << current
          encrypt_specific_file(path: current, password: password, version: force_legacy_encryption ? 1 : 2)
          UI.success("🔒  Encrypted '#{File.basename(current)}'") if FastlaneCore::Globals.verbose?
        end
        UI.success("🔒  Successfully encrypted certificates repo")
        return files
      end

      def decrypt_files
        files = []
        password = fetch_password!
        iterate(self.working_directory) do |current|
          files << current
          begin
            decrypt_specific_file(path: current, password: password)
          rescue => ex
            UI.verbose(ex.to_s)
            UI.error("Couldn't decrypt the repo, please make sure you enter the right password!")
            UI.user_error!("Invalid password passed via 'MATCH_PASSWORD'") if ENV["MATCH_PASSWORD"]
            clear_password
            self.decrypt_files # Call itself
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
        Dir[File.join(source_path, "**", "*.{cer,p12,mobileprovision,provisionprofile}")].each do |path|
          next if File.directory?(path)
          yield(path)
        end
      end

      # server name used for accessing the macOS keychain
      def server_name(keychain_name)
        ["match", keychain_name].join("_")
      end

      # Access the MATCH_PASSWORD, either from ENV variable, Keychain or user input
      def fetch_password!
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
            password = FastlaneCore::Helper.ask_password(message: "Passphrase for Match storage: ", confirm: true)
            store_password(password)
          end
        end

        return password
      end

      def encrypt_specific_file(path: nil, password: nil, version: nil)
        UI.user_error!("No password supplied") if password.to_s.strip.length == 0
        e = MatchFileEncryption.new
        e.encrypt(file_path: path, password: password, version: version)
      rescue FastlaneCore::Interface::FastlaneError
        raise
      rescue => error
        UI.error(error.to_s)
        UI.crash!("Error encrypting '#{path}'")
      end

      def decrypt_specific_file(path: nil, password: nil)
        e = MatchFileEncryption.new
        e.decrypt(file_path: path, password: password)
      rescue => error
        UI.error(error.to_s)
        UI.crash!("Error decrypting '#{path}'")
      end
    end
  end
end
