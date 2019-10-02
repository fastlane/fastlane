require 'fastlane_core/command_executor'
require 'fastlane_core/configuration/configuration'
require 'google/cloud/storage'

require_relative '../options'
require_relative '../module'
require_relative '../spaceship_ensure'
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
      attr_reader :google_cloud_project_id
      attr_reader :readonly
      attr_reader :username
      attr_reader :team_id
      attr_reader :team_name

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
          google_cloud_keys_file: params[:google_cloud_keys_file],
          google_cloud_project_id: params[:google_cloud_project_id],
          readonly: params[:readonly],
          username: params[:username],
          team_id: params[:team_id],
          team_name: params[:team_name]
        )
      end

      def initialize(type: nil,
                     platform: nil,
                     google_cloud_bucket_name: nil,
                     google_cloud_keys_file: nil,
                     google_cloud_project_id: nil,
                     readonly: nil,
                     username: nil,
                     team_id: nil,
                     team_name: nil)
        @type = type if type
        @platform = platform if platform
        @google_cloud_project_id = google_cloud_project_id if google_cloud_project_id
        @bucket_name = google_cloud_bucket_name

        @readonly = readonly
        @username = username
        @team_id = team_id
        @team_name = team_name

        @google_cloud_keys_file = ensure_keys_file_exists(google_cloud_keys_file, google_cloud_project_id)

        if self.google_cloud_keys_file.to_s.length > 0
          # Extract the Project ID from the `JSON` file
          # so the user doesn't have to provide it manually
          keys_file_content = JSON.parse(File.read(self.google_cloud_keys_file))
          if google_cloud_project_id.to_s.length > 0 && google_cloud_project_id != keys_file_content["project_id"]
            UI.important("The google_cloud_keys_file's project ID ('#{keys_file_content['project_id']}') doesn't match the google_cloud_project_id ('#{google_cloud_project_id}'). This may be the wrong keys file.")
          end
          @google_cloud_project_id = keys_file_content["project_id"]
          if self.google_cloud_project_id.to_s.length == 0
            UI.user_error!("Provided keys file on path #{File.expand_path(self.google_cloud_keys_file)} doesn't include required value for `project_id`")
          end
        end

        # Create the Google Cloud Storage client
        # If the JSON auth file is invalid, this line will
        # raise an exception
        begin
          self.gc_storage = Google::Cloud::Storage.new(
            credentials: self.google_cloud_keys_file,
            project_id: self.google_cloud_project_id
          )
        rescue => ex
          UI.error(ex)
          UI.verbose(ex.backtrace.join("\n"))
          UI.user_error!("Couldn't log into your Google Cloud account using the provided JSON file at path '#{File.expand_path(self.google_cloud_keys_file)}'")
        end

        ensure_bucket_is_selected
        check_bucket_permissions
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
        "Google Cloud Bucket [#{self.google_cloud_project_id}/#{self.bucket_name}]"
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

      def generate_matchfile_content
        return "bucket_name(\"#{self.bucket_name}\")"
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
      def ensure_keys_file_exists(google_cloud_keys_file, google_cloud_project_id)
        if google_cloud_keys_file && File.exist?(google_cloud_keys_file)
          return google_cloud_keys_file
        end

        return DEFAULT_KEYS_FILE_NAME if File.exist?(DEFAULT_KEYS_FILE_NAME)

        fastlane_folder_gc_keys_path = File.join(FastlaneCore::FastlaneFolder.path, DEFAULT_KEYS_FILE_NAME)
        return fastlane_folder_gc_keys_path if File.exist?(fastlane_folder_gc_keys_path)

        if google_cloud_project_id.to_s.length > 0
          # Check to see if this system has application default keys installed.
          # These are the default keys that the Google Cloud APIs use when no other keys are specified.
          # Users with the Google Cloud SDK installed can generate them by running...
          # `gcloud auth application-default login`
          # ...and then they'll be automatically available.
          # The nice thing about these keys is they can be associated with the user's login in GCP
          # (e.g. my_account@gmail.com), so teams can control access to the certificate bucket
          # using a mailing list of developer logins instead of generating service accounts
          # and keys.
          application_default_keys = nil
          begin
            application_default_keys = Google::Auth.get_application_default
          rescue
            # This means no application default keys have been installed. That's perfectly OK,
            # we can continue and ask the user if they want to use a keys file.
          end

          if application_default_keys && UI.confirm("Do you want to use this system's Google Cloud application default keys?")
            return nil
          end
        end

        # User doesn't seem to have provided a keys file
        UI.message("Looks like you don't have a Google Cloud #{DEFAULT_KEYS_FILE_NAME.cyan} file yet.")
        UI.message("If you have one, make sure to put it into the '#{Dir.pwd}' directory and call it '#{DEFAULT_KEYS_FILE_NAME.cyan}'.")
        unless UI.confirm("Do you want fastlane to help you to create a #{DEFAULT_KEYS_FILE_NAME} file?")
          UI.user_error!("Process stopped, run fastlane again to start things up again")
        end

        UI.message("fastlane will help you create a keys file. Start by opening the following website:")
        UI.message("")
        UI.message("\t\thttps://console.cloud.google.com".cyan)
        UI.message("")
        UI.input("Press [Enter] once you're logged in")

        UI.message("First, switch to the Google Cloud project you want to use.")
        UI.message("If you don't have one yet, create a new one and switch to it.")
        UI.message("")
        UI.message("\t\thttps://console.cloud.google.com/projectcreate".cyan)
        UI.message("")
        UI.input("Press [Enter] once you selected the right project")

        UI.message("Next fastlane will show you the steps to create a keys file.")
        UI.message("For this it might be useful to switch the Google Cloud interface to English.")
        UI.message("Append " + "&hl=en".cyan + " to the URL and the interface should be in English.")
        UI.input("Press [Enter] to continue")

        UI.message("Now it's time to generate a new JSON auth file for fastlane to access Google Cloud Storage:")
        UI.message("")
        UI.message("\t\t 1. From the side menu choose 'APIs & Services' and then 'Credentials'".cyan)
        UI.message("\t\t 2. Click 'Create credentials'".cyan)
        UI.message("\t\t 3. Choose 'Service account key'".cyan)
        UI.message("\t\t 4. Select 'New service account'".cyan)
        UI.message("\t\t 5. Enter a name and ID for the service account".cyan)
        UI.message("\t\t 6. Don't give the service account a role just yet!".cyan)
        UI.message("\t\t 7. Make sure the key type is set to 'JSON'".cyan)
        UI.message("\t\t 8. Click 'Create'".cyan)
        UI.message("")
        UI.input("Confirm with [Enter] once you created and downloaded the JSON file")

        UI.message("Copy the file to the current directory (#{Dir.pwd})")
        UI.message("and rename it to `#{DEFAULT_KEYS_FILE_NAME.cyan}`")
        UI.message("")
        UI.input("Confirm with [Enter]")

        until File.exist?(DEFAULT_KEYS_FILE_NAME)
          UI.message("Make sure to place the file in '#{Dir.pwd.cyan}' and name it '#{DEFAULT_KEYS_FILE_NAME.cyan}'")
          UI.message("")
          UI.input("Confirm with [Enter]")
        end

        UI.important("Please never add the #{DEFAULT_KEYS_FILE_NAME.cyan} file in version control.")
        UI.important("Instead please add the file to your `.gitignore` file")
        UI.message("")
        UI.input("Confirm with [Enter]")

        return DEFAULT_KEYS_FILE_NAME
      end

      def ensure_bucket_is_selected
        # Skip the instructions if the user provided a bucket name
        return unless self.bucket_name.to_s.length == 0

        created_bucket = UI.confirm("Did you already create a Google Cloud Storage bucket?")
        while self.bucket_name.to_s.length == 0
          unless created_bucket
            UI.message("Create a bucket at the following URL:")
            UI.message("")
            UI.message("\t\thttps://console.cloud.google.com/storage/browser".cyan)
            UI.message("")
            UI.message("Make sure to select the right project at the top of the page!")
            UI.message("")
            UI.message("\t\t 1. Click 'Create bucket'".cyan)
            UI.message("\t\t 2. Enter a unique name".cyan)
            UI.message("\t\t 3. Select a geographic location for your bucket".cyan)
            UI.message("\t\t 4. Make sure the storage class is set to 'Standard'".cyan)
            UI.message("\t\t 5. Click 'Create' to create the bucket".cyan)
            UI.message("")
            UI.input("Press [Enter] once you created a bucket")
          end
          bucket_name = UI.input("Enter the name of your bucket: ")

          # Verify if the bucket exists
          begin
            bucket_exists = !self.gc_storage.bucket(bucket_name).nil?
          rescue Google::Cloud::PermissionDeniedError
            bucket_exists = true
          end
          created_bucket = bucket_exists
          if bucket_exists
            @bucket_name = bucket_name
          else
            UI.error("It looks like the bucket '#{bucket_name}' doesn't exist. Make sure to create it first.")
          end
        end
      end

      def check_bucket_permissions
        bucket = nil
        while bucket.nil?
          begin
            bucket = self.gc_storage.bucket(self.bucket_name)
          rescue Google::Cloud::PermissionDeniedError
            bucket = nil
          end
          return if bucket.nil? == false
          UI.error("Looks like your Google Cloud account for the project ID '#{self.google_cloud_project_id}' doesn't")
          UI.error("have access to the storage bucket '#{self.bucket_name}'. Please visit the following URL:")
          UI.message("")
          UI.message("\t\thttps://console.cloud.google.com/storage/browser".cyan)
          UI.message("")
          UI.message("You need to give your account the correct permissions:")
          UI.message("")
          UI.message("\t\t 1. Click on your bucket to open it".cyan)
          UI.message("\t\t 2. Click 'Permissions'".cyan)
          UI.message("\t\t 3. Click 'Add members'".cyan)
          UI.message("\t\t 4. Enter the email of your service account".cyan)
          UI.message("\t\t 5. Set the role to 'Storage Admin'".cyan)
          UI.message("\t\t 6. Click 'Save'".cyan)
          UI.message("")
          UI.input("Confirm with [Enter] once you're finished")
        end
      end
    end
  end
end
