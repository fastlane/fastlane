require 'fastlane_core/command_executor'
require 'fastlane_core/configuration/configuration'
require 'google/cloud/storage'

require_relative '../options'
require_relative '../module'
require_relative './interface'

module Match
  module Storage
    # Store the code signing identities in on Google Cloud Storage
    class GoogleCloudStorage < Interface
      DEFAULT_KEYS_FILE_NAME = "gc_keys.json"

      # User provided values
      attr_reader :type
      attr_reader :platform
      attr_reader :bucket_name
      attr_reader :google_cloud_keys_file
      attr_reader :project_id

      # Managed values
      attr_accessor :gc_storage

      def self.configure(params)
        if params[:git_url].to_s.length > 0
          UI.important("Looks like you still define a `git_url` somewhere, even though")
          UI.important("you use Google Cloud Storage. You can remove the `git_url`")
          UI.important("from your Matchfile and Fastfile")
          UI.message("The above is just a warning, fastlane will continue as usual now...")
        end

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
        @type = type if type
        @platform = platform if platform
        @bucket_name = google_cloud_bucket_name

        @google_cloud_keys_file = ensure_keys_file_exists(google_cloud_keys_file)

        # Extract the Project ID from the `JSON` file
        # so the user doesn't have to provide it manually
        keys_file_content = JSON.parse(File.read(self.google_cloud_keys_file))
        @project_id = keys_file_content["project_id"]
        if self.project_id.to_s.length == 0
          UI.user_error!("Provided keys file on path #{File.expand_path(self.google_cloud_keys_file)} doesn't include required value for `project_id`")
        end

        # Create the Google Cloud Storage client
        # If the JSON auth file is invalid, this line will
        # raise an exception
        begin
          self.gc_storage = Google::Cloud::Storage.new(
            credentials: self.google_cloud_keys_file,
            project_id: self.project_id
          )
        rescue => ex
          UI.error(ex)
          UI.verbose(ex.backtrace.join("\n"))
          UI.user_error!("Couldn't log into your Google Cloud account using the provided JSON file at path '#{File.expand_path(self.google_cloud_keys_file)}'")
        end

        ensure_bucket_is_selected
      end

      def download
        # Check if we already have a functional working_directory
        return if @working_directory

        # No existing working directory, creating a new one now
        self.working_directory = Dir.mktmpdir

        bucket.files.each do |current_file|
          file_path = current_file.name # e.g. "N8X438SEU2/certs/distribution/XD9G7QCACF.cer"
          download_path = File.join(self.working_directory, file_path)

          FileUtils.mkdir_p(File.expand_path("..", download_path))
          UI.verbose("Downloading file from Google Cloud Storage '#{file_path}' on bucket #{self.bucket_name}")
          current_file.download(download_path)
        end
        UI.verbose("Successfully downloaded files from GCS to #{self.working_directory}")
      end

      def delete_files(files_to_delete: [], custom_message: nil)
        files_to_delete.each do |current_file|
          target_path = current_file.gsub(self.working_directory + "/", "")
          file = bucket.file(target_path)
          UI.message("Deleting '#{target_path}' from Google Cloud Storage bucket '#{self.bucket_name}'...")
          file.delete
        end
      end

      def human_readable_description
        "Google Cloud Bucket [#{self.project_id}/#{self.bucket_name}]"
      end

      def upload_files(files_to_upload: [], custom_message: nil)
        # `files_to_upload` is an array of files that need to be uploaded to Google Cloud
        # Those doesn't mean they're new, it might just be they're changed
        # Either way, we'll upload them using the same technique

        files_to_upload.each do |current_file|
          # Go from
          #   "/var/folders/px/bz2kts9n69g8crgv4jpjh6b40000gn/T/d20181026-96528-1av4gge/profiles/development/Development_me.mobileprovision"
          # to
          #   "profiles/development/Development_me.mobileprovision"
          #

          # We also have to remove the trailing `/` as Google Cloud doesn't handle it nicely
          target_path = current_file.gsub(self.working_directory + "/", "")
          UI.verbose("Uploading '#{target_path}' to Google Cloud Storage...")
          bucket.create_file(current_file, target_path)
        end
      end

      def skip_docs
        false
      end

      private

      def bucket
        @_bucket ||= self.gc_storage.bucket(self.bucket_name)

        if @_bucket.nil?
          UI.user_error!("Couldn't find Google Cloud Storage bucket with name #{self.bucket_name} for the currently used account. Please make sure you have access")
        end

        return @_bucket
      end

      ##########################
      # Setup related methods
      ##########################

      # This method will make sure the keys file exists
      # If it's missing, it will help the user set things up
      def ensure_keys_file_exists(google_cloud_keys_file)
        if google_cloud_keys_file && File.exist?(google_cloud_keys_file)
          return google_cloud_keys_file
        end

        return DEFAULT_KEYS_FILE_NAME if File.exist?(DEFAULT_KEYS_FILE_NAME)

        fastlane_folder_gc_keys_path = File.join(FastlaneCore::FastlaneFolder.path, DEFAULT_KEYS_FILE_NAME)
        return fastlane_folder_gc_keys_path if File.exist?(fastlane_folder_gc_keys_path)

        # User doesn't seem to have provided a keys file
        UI.message("Looks like you don't have a Google Cloud #{DEFAULT_KEYS_FILE_NAME.cyan} file yet")
        UI.message("If you have one, make sure to put it into the '#{Dir.pwd}' directory and call it '#{DEFAULT_KEYS_FILE_NAME.cyan}'")
        unless UI.confirm("Do you want fastlane to help you to create a #{DEFAULT_KEYS_FILE_NAME} file?")
          UI.user_error!("Process stopped, run fastlane again to start things up again")
        end

        UI.message("fastlane will help you create a keys file. First, open the following website")
        UI.message("")
        UI.message("\t\thttps://console.cloud.google.com".cyan)
        UI.message("")
        UI.input("Press enter once you're logged in")

        UI.message("Now it's time to generate a new JSON auth file for fastlane to access Google Cloud")
        UI.message("First, switch to the Google Cloud project you want to use.")
        UI.message("If you don't have one yet, create a new one and switch to it")
        UI.message("")
        UI.message("\t\thttps://console.cloud.google.com/apis/credentials".cyan)
        UI.message("")
        UI.input("Ensure the right project is selected on top of the page and confirm with enter")

        UI.message("Now create a new JSON auth file by clicking on")
        UI.message("")
        UI.message("\t\t 1. Create credentials".cyan)
        UI.message("\t\t 2. Service account key".cyan)
        UI.message("\t\t 3. App Engine default service account".cyan)
        UI.message("\t\t 4. JSON".cyan)
        UI.message("\t\t 5. Create".cyan)
        UI.message("")
        UI.input("Confirm with enter once you created and download the JSON file")

        UI.message("Copy the file to the current directory (#{Dir.pwd})")
        UI.message("and rename it to `#{DEFAULT_KEYS_FILE_NAME.cyan}`")
        UI.message("")
        UI.input("Confirm with enter")

        until File.exist?(DEFAULT_KEYS_FILE_NAME)
          UI.message("Make sure to place the file in '#{Dir.pwd.cyan}' and name it '#{DEFAULT_KEYS_FILE_NAME.cyan}'")
          UI.input("Confirm with enter")
        end

        UI.important("Please never add the #{DEFAULT_KEYS_FILE_NAME.cyan} file in version control.")
        UI.important("Instead please add the file to your .gitignore")
        UI.input("Confirm with enter")

        return DEFAULT_KEYS_FILE_NAME
      end

      def ensure_bucket_is_selected
        # In case the user didn't provide a bucket name yet, they will
        # be asked to provide one here
        while self.bucket_name.to_s.length == 0
          # Have a nice selection of the available buckets here
          # This can only happen after we went through auth of Google Cloud
          available_bucket_identifiers = self.gc_storage.buckets.collect(&:id)
          if available_bucket_identifiers.count > 0
            @bucket_name = UI.select("What Google Cloud Storage bucket do you want to use? (you can define it using the `google_cloud_bucket_name` key)", available_bucket_identifiers)
          else
            UI.error("Looks like your Google Cloud account for the project ID '#{self.project_id}' doesn't")
            UI.error("have any available storage buckets yet. Please visit the following URL")
            UI.message("")
            UI.message("\t\thttps://console.cloud.google.com/storage/browser".cyan)
            UI.message("")
            UI.message("and make sure to have the right project selected on top of the page")
            UI.message("click on " + "Create Bucket".cyan + ", choose a name and confirm")
            UI.message("")
            UI.input("Once you're finished, please confirm with enter")
          end
        end
      end
    end
  end
end
