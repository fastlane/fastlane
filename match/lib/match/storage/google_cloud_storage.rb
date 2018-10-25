require 'fastlane_core/command_executor'

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
      end

      def download
        # Check if we already have a functional working_directory
        return self.working_directory if @working_directory

        # No existing working directory, creating a new one now
        self.working_directory = Dir.mktmpdir

        # TODO: implement
      end

      def save_changes!(files_to_commit: [], custom_message: nil)
        # TODO: implement
      end
    end
  end
end
