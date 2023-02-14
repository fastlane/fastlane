require "fastlane_core/command_executor"
require "fastlane_core/configuration/configuration"
require "zlib"
require "base64"
require "aws-sdk-secretsmanager"

require_relative "../options"
require_relative "../module"
require_relative "../spaceship_ensure"
require_relative "./interface"

module Match
  module Storage
    # Store the code signing identities on AWS Secrets Manager
    class AWSSecretsManagerStorage < Interface
      attr_reader :aws_sm_client
      attr_reader :region
      attr_reader :delete_without_recovery
      attr_reader :recovery_window_days
      attr_reader :prefix
      attr_reader :username
      attr_reader :team_id
      attr_reader :team_name
      attr_reader :readonly
      attr_reader :api_key_path
      attr_reader :api_key

      def self.configure(params)
        aws_secrets_manager_region = params[:aws_secrets_manager_region]
        aws_secrets_manager_prefix = params[:aws_secrets_manager_prefix]
        aws_secrets_manager_access_key = params[:aws_secrets_manager_access_key]
        aws_secrets_manager_secret_access_key = params[:aws_secrets_manager_secret_access_key]
        delete_without_recovery = params[:aws_secrets_manager_force_delete_without_recovery]
        recovery_window_days = params[:aws_secrets_manager_recovery_window_days]

        UI.important("You are using AWS Secrets Manager as your storage which is a PAID SERVICE and has USAGE LIMITS.")

        if recovery_window_days && recovery_window_days < 7
          UI.user_error!("The aws_secrets_manager_recovery_window_days must be at least 7 days")
        end

        if delete_without_recovery && recovery_window_days
          UI.user_error!("You can't use both `aws_secrets_manager_force_delete_without_recovery` and `aws_secrets_manager_recovery_window_days`")
        end

        return self.new(
          aws_secrets_manager_region: aws_secrets_manager_region,
          aws_secrets_manager_prefix: aws_secrets_manager_prefix,
          delete_without_recovery: delete_without_recovery,
          recovery_window_days: recovery_window_days,
          username: params[:username],
          team_id: params[:team_id],
          team_name: params[:team_name],
          readonly: params[:readonly],
          aws_secrets_manager_access_key: aws_secrets_manager_access_key,
          aws_secrets_manager_secret_access_key: aws_secrets_manager_secret_access_key,
          api_key_path: params[:api_key_path],
          api_key: params[:api_key]
        )
      end

      def initialize(aws_secrets_manager_region: nil,
                     aws_secrets_manager_prefix: nil,
                     delete_without_recovery: nil,
                     recovery_window_days: nil,
                     username: nil,
                     team_id: nil,
                     team_name: nil,
                     readonly: nil,
                     aws_secrets_manager_access_key: nil,
                     aws_secrets_manager_secret_access_key: nil,
                     api_key_path: nil,
                     api_key: nil)
        @prefix = aws_secrets_manager_prefix.to_s
        @delete_without_recovery = delete_without_recovery
        @recovery_window_days = recovery_window_days
        @username = username
        @team_id = team_id
        @team_name = team_name
        @readonly = readonly
        @api_key_path = api_key_path
        @api_key = api_key

        @aws_sm_client = Aws::SecretsManager::Client.new({ region: aws_secrets_manager_region, credentials: create_credentials(aws_secrets_manager_access_key, aws_secrets_manager_secret_access_key) }.compact)
      end

      def create_credentials(access_key, secret_access_key)
        return nil if access_key.to_s.empty? || secret_access_key.to_s.empty?

        Aws::Credentials.new(
          access_key,
          secret_access_key
        )
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
          UI.important("Looks like you run `match` in `readonly` mode, and didn't provide a `team_id`. This will still work, however it HIGHLY recommended to provide a `team_id` in your Appfile or Matchfile. There are quota limits you will hit and Secrets manager is not used for fun!")
          @_folder_prefix = "*"
        end
        return File.join(working_directory, @_folder_prefix)
      end

      def download
        # Check if we already have a functional working_directory
        return if @working_directory && Dir.exist?(@working_directory)

        # No existing working directory, creating a new one now
        self.working_directory = Dir.mktmpdir

        secret_list = []
        next_token = nil
        loop do
          response = aws_sm_client.list_secrets({
            max_results: 100,
            next_token: next_token,
            filters: [
              {
                key: "name",
                values: ["#{prefix}#{!currently_used_team_id.nil? ? currently_used_team_id.to_s : ''}"]
              }
            ]
          }.compact)
          secret_list += response.secret_list
          next_token = response.next_token
          break unless next_token
        end

        secret_list.each do |secret|
          UI.message("Downloading '#{secret.name}' from Secrets Manager")

          retrieved_secret = aws_sm_client.get_secret_value({
            secret_id: secret.arn
          })
          if retrieved_secret.secret_binary.nil?
             next
           end
          decoded_secret = Zlib::Inflate.inflate(Base64.decode64(retrieved_secret.secret_binary))
          stripped_secret_name = strip_secrets_manager_object_prefix(secret.name)
          download_path = File.join(self.working_directory, stripped_secret_name)
          FileUtils.mkdir_p(File.expand_path("..", download_path))
          File.write(download_path, decoded_secret)
        end

        UI.message("Successfully downloaded files from AWS Secrets Manager to #{self.working_directory}")
      end

      def human_readable_description
        return "AWS Secrets Manager region '#{region}'"
      end

      def upload_files(files_to_upload: [], custom_message: nil)
        # `files_to_upload` is an array of files that need to be uploaded to Secrets manager
        # Those doesn't mean they're new, it might just be they're changed
        # Either way, we'll upload them using the same technique

        files_to_upload.each do |file_name|
          # Go from
          #   "/var/folders/px/bz2kts9n69g8crgv4jpjh6b40000gn/T/d20181026-96528-1av4gge/:team_id/profiles/development/Development_me.mobileprovision"
          # to
          #   ":prefix:team_id-profiles-development-Development_me.mobileprovision"
          #
          target_path = secrets_manager_object_path(file_name)
          UI.verbose("Uploading '#{target_path}' to Secrets manager...")
          secret_base64_binary = Base64.encode64(Zlib::Deflate.deflate(File.read(file_name)))
          begin
            response = aws_sm_client.describe_secret({
              secret_id: target_path,
            })
            rescue Aws::SecretsManager::Errors::ResourceNotFoundException
              UI.message("The secret #{target_path} was not found, creating...")
              aws_sm_client.create_secret({
                name: target_path,
                secret_binary: secret_base64_binary,
              })
            rescue Aws::SecretsManager::Errors::LimitExceededException
              UI.error("You have reached the request quota, wait a minute or two. Or (unlikely) you have reached the maximum number of secrets (most probably 50,000) allowed for your account. In that case delete some secrets and try again.")
          else
            if response.key?(:deleted_date)
              UI.verbose("The secret #{target_path} was deleted on #{response[:deleted_date]}, restoring and updating...")
              aws_sm_client.restore_secret({
                secret_id: target_path,
              })
            else
              UI.verbose("The secret #{target_path} already exists, updating...")
            end

            response = aws_sm_client.update_secret({
              secret_id: target_path,
              secret_binary: secret_base64_binary,
            })
            UI.verbose("Uploaded '#{response[:arn]}' to Secrets manager.")
          end
        end
      end

      def delete_files(files_to_delete: [], custom_message: nil)
        files_to_delete.each do |file_name|
          target_path = secrets_manager_object_path(file_name)
          UI.verbose("Deleting '#{target_path}' from Secrets manager...")
          aws_sm_client.delete_secret({
            recovery_window_in_days: recovery_window_days,
            force_delete_without_recovery: delete_without_recovery,
            secret_id: target_path,
          }.compact)
          UI.verbose("Deleted '#{target_path}' from Secrets manager...")
        end
      end

      def list_files(file_name: "", file_ext: "")
        Dir[File.join(working_directory, self.team_id, "**", file_name, "*.#{file_ext}")]
      end

      def generate_matchfile_content(template: nil)
        return "aws_secrets_manager_region(\"#{self.aws_secrets_manager_region}\")"
      end

      def skip_docs
        false
      end

      private

      def secrets_manager_object_path(file_name)
        sanitized = sanitize_file_name(file_name)
        return sanitized if sanitized.start_with?(prefix)

        prefix + sanitized
      end

      def strip_secrets_manager_object_prefix(object_path)
        object_path.gsub(/^#{prefix}/, "")
      end

      def sanitize_file_name(file_name)
        file_name.gsub(self.working_directory + "/", "")
      end

      def currently_used_team_id
        if self.readonly
          # In readonly mode, we still want to see if the user provided a team_id
          # see `prefixed_working_directory` comments for more details
          return self.team_id
        else
          UI.user_error!("The `team_id` option is required. fastlane cannot automatically determine portal team id via the App Store Connect API (yet)") if self.team_id.to_s.empty?

          spaceship = SpaceshipEnsure.new(self.username, self.team_id, self.team_name, api_token)
          return spaceship.team_id
        end
      end

      def api_token
        api_token = Spaceship::ConnectAPI::Token.from(hash: self.api_key, filepath: self.api_key_path)
        api_token ||= Spaceship::ConnectAPI.token
        return api_token
      end
    end
  end
end
