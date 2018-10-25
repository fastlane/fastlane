require 'base64'
require 'openssl'
require 'securerandom'
require 'security'
require 'shellwords'

require_relative '../module'

module Match
  module Encryption
    class GoogleCloudKMS < Interface
      attr_accessor :key_path

      attr_accessor :working_directory

      def self.configure(params)
        return self.new(
          key_path: params[:key_path],
          working_directory: params[:working_directory]
        )
      end

      # @param key_path: # TODO
      # @param working_directory: The path to where the certificates are stored
      def initialize(key_path: nil, working_directory: nil)
        self.key_path = key_path
        self.working_directory = working_directory
      end

      def encrypt_files
        iterate(self.working_directory) do |current|
          encrypt_specific_file(path: current)
          UI.success("🔒  Encrypted '#{File.basename(current)}'") if FastlaneCore::Globals.verbose?
        end
        UI.success("🔒  Successfully encrypted certificates repo")
      end

      def decrypt_files
        iterate(self.working_directory) do |current|
          begin
            decrypt_specific_file(path: current)
          rescue => ex
            UI.verbose(ex.to_s)
            # TODO: actual error message
            UI.error("Couldn't decrypt the repo, please make sure you enter the right password!")
            raise ex
          end
          UI.success("🔓  Decrypted '#{File.basename(current)}'") if FastlaneCore::Globals.verbose?
        end
        UI.success("🔓  Successfully decrypted certificates repo")
      end

      private

      def iterate(source_path)
        Dir[File.join(source_path, "**", "*.{cer,p12,mobileprovision}")].each do |path|
          next if File.directory?(path)
          yield(path)
        end
      end

      def encrypt_specific_file(path: nil)
        # TODO: implement
      end

      def decrypt_specific_file(path: nil)
        # TODO: implement
      end
    end
  end
end
