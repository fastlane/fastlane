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

      # Append Google Cloud specific options to `Match::Options`
      Match::Options.append_option(
        FastlaneCore::ConfigItem.new(
          key: :google_cloud_bucket_name,
          env_name: "MATCH_GOOGLE_CLOUD_BUCKET_NAME",
          description: "Name of the Google Cloud Storage bucket to use",
          optional: true
        )
      )
      Match::Options.append_option(
        FastlaneCore::ConfigItem.new(
          key: :google_cloud_keys_file,
          env_name: "MATCH_GOOGLE_CLOUD_KEYS_FILE",
          description: "Path to the `gc_keys.json` file",
          optional: true,
          verify_block: proc do |value|
            UI.user_error!("Could not find keys file at path '#{File.expand_path(value)}'") unless File.exist?(value)
          end
        )
      )

      def self.configure(params)
        return self.new(
          type: params[:type].to_s,
          platform: params[:platform].to_s,
          google_cloud_bucket_name: params[:google_cloud_bucket_name],
          google_cloud_keys_file: params[:google_cloud_keys_file]
        )
      end

      def initialize(type: nil,
                     platform: nil,
                     google_cloud_bucket_name: nil,
                     google_cloud_keys_file: nil)
        self.type = type if type
        self.platform = platform if platform
        self.bucket_name = google_cloud_bucket_name

        keys_file_content = JSON.parse(File.read(google_cloud_keys_file))
        project_id = keys_file_content["project_id"]
        if project_id.to_s.length == 0
          UI.user_error!("Provided keys file on path #{File.expand_path(google_cloud_keys_file)} doesn't include required value for `project_id`")
        end

        self.gc_storage = Google::Cloud::Storage.new(
          credentials: google_cloud_keys_file,
          project_id: project_id
        )
      end

      def download
        # Check if we already have a functional working_directory
        return self.working_directory if @working_directory

        # No existing working directory, creating a new one now
        self.working_directory = Dir.mktmpdir

        # TODO: error handling
        # TODO: create bucket for the user
        # TODO: verify permission
        bucket.files.each do |current_file|
          file_path = current_file.url.split(self.bucket_name).last # TODO: is there a way to get the full path without this
          download_path = File.join(self.working_directory, file_path)

          FileUtils.mkdir_p(File.expand_path("..", download_path))
          UI.verbose("Downloading file from Google Cloud Storage '#{file_path}'")
          current_file.download(download_path)
        end
        UI.verbose("Successfully downloaded files from GCS to #{self.working_directory}")
      end

      def save_changes!(files_to_commit: [], files_to_delete: [], custom_message: nil)
        # the `custom_message` will be ignored by the GCS implementation
        # TODO: migrate the new header and checks over to git_storage
        Dir.chdir(File.expand_path(self.working_directory)) do
          if files_to_commit.count > 0 # everything that isn't `match nuke`
            UI.user_error!("You can't provide both `files_to_delete` and `files_to_commit` right now") if files_to_delete.count > 0

            if !File.exist?(MATCH_VERSION_FILE_NAME) || File.read(MATCH_VERSION_FILE_NAME) != Fastlane::VERSION.to_s
              files_to_commit << MATCH_VERSION_FILE_NAME
              File.write(MATCH_VERSION_FILE_NAME, Fastlane::VERSION) # stored unencrypted
            end

            # TODO: how to deal with README
            template = File.read("#{Match::ROOT}/lib/assets/READMETemplate.md")
            readme_path = "README.md"
            if !File.exist?(readme_path) || File.read(readme_path) != template
              files_to_commit << readme_path
              File.write(readme_path, template)
            end

            # TODO: encryption as part of
            # https://googleapis.github.io/google-cloud-ruby/docs/google-cloud-storage/latest/

            files_to_commit.map do |current_file|
              # Go from
              #   "/var/folders/px/bz2kts9n69g8crgv4jpjh6b40000gn/T/d20181026-96528-1av4gge/profiles/development/Development_me.mobileprovision"
              # to
              #   "profiles/development/Development_me.mobileprovision"
              #
              # TODO: prefix with team_id?

              # We also have to remove the trailing `/` as Google Cloud doesn't handle it nicely
              target_path = current_file.gsub(self.working_directory + "/", "") # TODO: maybe find a better solution for this
              UI.verbose("Uploading '#{target_path}' to Google Cloud Storage...")
              bucket.create_file(current_file, target_path)
            end
          elsif files_to_delete.count > 0
            # This code is used currently only for `fastlane match nuke`
            # TODO
            files_to_delete.each do |current_file|
              target_path = current_file.gsub(self.working_directory + "/", "") # TODO: maybe find a better solution for this
              file = bucket.file(target_path)
              UI.message("Deleting '#{target_path}' from Google Cloud Storage...")
              file.delete
            end
          else
            UI.user_error!("Neither `files_to_commit` nor `files_to_delete` were provided to the `save_changes!` method call")
          end

          UI.message("Finished pushing changes up to Google Cloud Storage")
        end
      end

      private

      def bucket
        if self.bucket_name.to_s.length == 0
          # Have a nice selection of the available buckets here
          # This happens deeper down in the stack, as it requires
          # us to already be authenticated with Google Cloud
          available_bucket_identifiers = self.gc_storage.buckets.collect(&:id)
          self.bucket_name = UI.select("What Google Cloud Storage bucket do you want to use?", available_bucket_identifiers)
        end
        # TODO: `google_cloud_bucket_name` isn't actually assigned after selection

        @_bucket ||= self.gc_storage.bucket(self.bucket_name)

        if @_bucket.nil?
          UI.user_error!("Couldn't find Google Cloud Storage bucket with name #{self.bucket_name} for the currently used account. Please make sure you have access")
        end

        return @_bucket
      end
    end
  end
end
