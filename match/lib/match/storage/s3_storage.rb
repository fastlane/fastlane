require 'fastlane_core/command_executor'
require 'fastlane_core/configuration/configuration'
require 'fastlane/helper/s3_client_helper'

require_relative '../options'
require_relative '../module'
require_relative '../spaceship_ensure'
require_relative './interface'

module Match
  module Storage
    # Store the code signing identities on AWS S3
    class S3Storage < Interface
      attr_reader :s3_bucket
      attr_reader :s3_region
      attr_reader :s3_client
      attr_reader :readonly
      attr_reader :username
      attr_reader :team_id
      attr_reader :team_name

      def self.configure(params)
        s3_region = params[:s3_region]
        s3_access_key = params[:s3_access_key]
        s3_secret_access_key = params[:s3_secret_access_key]
        s3_bucket = params[:s3_bucket]

        if params[:git_url].to_s.length > 0
          UI.important("Looks like you still define a `git_url` somewhere, even though")
          UI.important("you use S3 Storage. You can remove the `git_url`")
          UI.important("from your Matchfile and Fastfile")
          UI.message("The above is just a warning, fastlane will continue as usual now...")
        end

        return self.new(
          s3_region: s3_region,
          s3_access_key: s3_access_key,
          s3_secret_access_key: s3_secret_access_key,
          s3_bucket: s3_bucket,
          readonly: params[:readonly],
          username: params[:username],
          team_id: params[:team_id],
          team_name: params[:team_name]
        )
      end

      def initialize(s3_region: nil,
                     s3_access_key: nil,
                     s3_secret_access_key: nil,
                     s3_bucket: nil,
                     readonly: nil,
                     username: nil,
                     team_id: nil,
                     team_name: nil)
        @s3_bucket = s3_bucket
        @s3_region = s3_region
        @s3_client = Fastlane::Helper::S3ClientHelper.new(access_key: s3_access_key, secret_access_key: s3_secret_access_key, region: s3_region)
        @readonly = readonly
        @username = username
        @team_id = team_id
        @team_name = team_name
      end

      # To make debugging easier, we have a custom exception here
      def prefixed_working_directory
        # We fall back to "*", which means certificates and profiles
        # from all teams that use this bucket would be installed. This is not ideal, but
        # unless the user provides a `team_id`, we can't know which one to use
        # This only happens if `readonly` is activated, and no `team_id` was provided
        @_folder_prefix ||= currently_used_team_id
        if @_folder_prefix.nil?
          # We use a `@_folder_prefix` variable, to keep state between multiple calls of this
          # method, as the value won't change. This way the warning is only printed once
          UI.important("Looks like you run `match` in `readonly` mode, and didn't provide a `team_id`. This will still work, however it is recommended to provide a `team_id` in your Appfile or Matchfile")
          @_folder_prefix = "*"
        end
        return File.join(working_directory, @_folder_prefix)
      end

      # Call this method for the initial clone/download of the
      # user's certificates & profiles
      # As part of this method, the `self.working_directory` attribute
      # will be set
      def download
        # Check if we already have a functional working_directory
        return if @working_directory && Dir.exist?(@working_directory)

        # No existing working directory, creating a new one now
        self.working_directory = Dir.mktmpdir

        s3_client.find_bucket!(s3_bucket).objects.each do |object|
          file_path = object.key # :team_id/path/to/file
          download_path = File.join(self.working_directory, file_path)

          FileUtils.mkdir_p(File.expand_path("..", download_path))
          UI.verbose("Downloading file from S3 '#{file_path}' on bucket #{self.s3_bucket}")

          object.download_file(download_path)
        end
        UI.verbose("Successfully downloaded files from S3 to #{self.working_directory}")
      end

      # Returns a short string describing + identifing the current
      # storage backend. This will be printed when nuking a storage
      def human_readable_description
        return "S3 Bucket [#{s3_bucket}] on region #{s3_region}"
      end

      def upload_files(files_to_upload: [], custom_message: nil)
        # `files_to_upload` is an array of files that need to be uploaded to S3
        # Those doesn't mean they're new, it might just be they're changed
        # Either way, we'll upload them using the same technique

        files_to_upload.each do |file_name|
          # Go from
          #   "/var/folders/px/bz2kts9n69g8crgv4jpjh6b40000gn/T/d20181026-96528-1av4gge/profiles/development/Development_me.mobileprovision"
          # to
          #   "profiles/development/Development_me.mobileprovision"
          #

          target_path = sanitize_file_name(file_name)
          UI.verbose("Uploading '#{target_path}' to S3 Storage...")

          body = File.read(file_name)
          acl = 'private'
          s3_url = s3_client.upload_file(s3_bucket, target_path, body, acl)
          UI.verbose("Uploaded '#{s3_url}' to S3 Storage.")
        end
      end

      def delete_files(files_to_delete: [], custom_message: nil)
        files_to_delete.each do |file_name|
          target_path = sanitize_file_name(file_name)
          s3_client.delete_file(s3_bucket, target_path)
        end
      end

      def skip_docs
        false
      end

      # Implement this for the `fastlane match init` command
      # This method must return the content of the Matchfile
      # that should be generated
      def generate_matchfile_content(template: nil)
        return "s3_bucket(\"#{self.s3_bucket}\")"
      end

      private

      def sanitize_file_name(file_name)
        file_name.gsub(self.working_directory + "/", "")
      end

      def currently_used_team_id
        if self.readonly
          # In readonly mode, we still want to see if the user provided a team_id
          # see `prefixed_working_directory` comments for more details
          return self.team_id
        else
          spaceship = SpaceshipEnsure.new(self.username, self.team_id, self.team_name)
          return spaceship.team_id
        end
      end
    end
  end
end
