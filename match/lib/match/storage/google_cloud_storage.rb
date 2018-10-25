require 'fastlane_core/command_executor'
require 'google/cloud/storage'

require_relative '../module'
require_relative './interface'

module Match
  module Storage
    # Store the code signing identities in on Google Cloud Storage
    class GoogleCloudStorage < Interface
      MATCH_VERSION_FILE_NAME = "match_version.txt"

      # User provided values
      attr_accessor :type
      attr_accessor :platform
      attr_accessor :bucket_name

      # Managed values
      attr_accessor :gc_storage

      def self.configure(params)
        return self.new(
          type: params[:type].to_s,
          platform: params[:platform].to_s
        )
      end

      def initialize(type: nil,
                     platform: nil)
        self.type = type if type
        self.platform = platform if platform

        self.bucket_name = "fastlane-kms-testing" # TODO: 

        self.gc_storage = Google::Cloud::Storage.new(
          project_id: "fastlane-kms-testing",
          credentials: "./keys.json"
        )
      end

      def download
        # Check if we already have a functional working_directory
        return self.working_directory if @working_directory

        # No existing working directory, creating a new one now
        self.working_directory = Dir.mktmpdir

        bucket = self.gc_storage.bucket(self.bucket_name)
        # TODO: error handling
        # TODO: create bucket for the user
        # TODO: verify permission
        bucket.files.each do |current_file|
          file_path = current_file.url.split(self.bucket_name).last # TODO: is there a way to get the full path without this
          download_path = File.join(self.working_directory, file_path)

          FileUtils.mkdir_p(File.expand_path("..", download_path))
          UI.verbose("Download file from Google Cloud storage '#{file_path}'")
          current_file.download(download_path)
        end
      end

      def save_changes!(files_to_commit: [], custom_message: nil)
        # TODO: implement
      end
    end
  end
end
