require 'fastlane_core/command_executor'
require 'fastlane_core/configuration/configuration'
require 'net/http/post/multipart'

require_relative './gitlab/client'
require_relative './gitlab/secure_file'

require_relative '../options'
require_relative '../module'
require_relative '../spaceship_ensure'
require_relative './interface'

module Match
  module Storage
    # Store the code signing identities in GitLab Secure Files
    class GitLabSecureFiles < Interface
      attr_reader :gitlab_client
      attr_reader :project_id
      attr_reader :readonly
      attr_reader :username
      attr_reader :team_id
      attr_reader :team_name
      attr_reader :api_key_path
      attr_reader :api_key
      attr_reader :api_v4_url

      def self.configure(params)
        api_v4_url     = ENV['CI_API_V4_URL'] || "#{params[:gitlab_host]}/api/v4"
        project_id     = params[:gitlab_project] || ENV['GITLAB_PROJECT'] || ENV['CI_PROJECT_ID']
        job_token      = params[:job_token] || ENV['CI_JOB_TOKEN']
        private_token  = params[:private_token] || ENV['PRIVATE_TOKEN']

        if params[:git_url].to_s.length > 0
          UI.important("Looks like you still define a `git_url` somewhere, even though")
          UI.important("you use GitLab Secure Files. You can remove the `git_url`")
          UI.important("from your Matchfile and Fastfile")
          UI.message("The above is just a warning, fastlane will continue as usual now...")
        end

        return self.new(
          api_v4_url: api_v4_url,
          project_id: project_id,
          job_token: job_token,
          private_token: private_token,
          readonly: params[:readonly],
          username: params[:username],
          team_id: params[:team_id],
          team_name: params[:team_name],
          api_key_path: params[:api_key_path],
          api_key: params[:api_key],
          gitlab_host: params[:gitlab_host]
        )
      end

      def initialize(api_v4_url: nil,
                     project_id: nil,
                     job_token: nil,
                     private_token: nil,
                     readonly: nil,
                     username: nil,
                     team_id: nil,
                     team_name: nil,
                     api_key_path: nil,
                     api_key: nil,
                     gitlab_host: nil)

        @readonly = readonly
        @username = username
        @team_id = team_id
        @team_name = team_name
        @api_key_path = api_key_path
        @api_key = api_key
        @gitlab_host = gitlab_host

        @job_token = job_token
        @private_token = private_token
        @api_v4_url = api_v4_url
        @project_id = project_id
        @gitlab_client = GitLab::Client.new(job_token: @job_token, private_token: @private_token, project_id: @project_id, api_v4_url: @api_v4_url)

        UI.message("Initializing match for GitLab project #{@project_id} on #{@gitlab_host}")
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

      def download
        gitlab_client.prompt_for_access_token

        # Check if we already have a functional working_directory
        return if @working_directory

        # No existing working directory, creating a new one now
        self.working_directory = Dir.mktmpdir

        @gitlab_client.files.each do |secure_file|
          secure_file.download(self.working_directory)
        end

        UI.verbose("Successfully downloaded all Secure Files from GitLab to #{self.working_directory}")
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

      # Returns a short string describing + identifying the current
      # storage backend. This will be printed when nuking a storage
      def human_readable_description
        "GitLab Secure Files Storage [#{self.project_id}]"
      end

      def upload_files(files_to_upload: [], custom_message: nil)
        # `files_to_upload` is an array of files that need to be uploaded to GitLab Secure Files
        # Those doesn't mean they're new, it might just be they're changed
        # Either way, we'll upload them using the same technique

        files_to_upload.each do |current_file|
          # Go from
          #   "/var/folders/px/bz2kts9n69g8crgv4jpjh6b40000gn/T/d20181026-96528-1av4gge/profiles/development/Development_me.mobileprovision"
          # to
          #   "profiles/development/Development_me.mobileprovision"
          #

          # We also remove the trailing `/`
          target_file = current_file.gsub(self.working_directory + "/", "")
          UI.verbose("Uploading '#{target_file}' to GitLab Secure Files...")
          @gitlab_client.upload_file(current_file, target_file)
        end
      end

      def delete_files(files_to_delete: [], custom_message: nil)
        files_to_delete.each do |current_file|
          target_path = current_file.gsub(self.working_directory + "/", "")

          secure_file = @gitlab_client.find_file_by_name(target_path)
          UI.message("Deleting '#{target_path}' from GitLab Secure Files...")
          secure_file.delete
        end
      end

      def skip_docs
        true
      end

      def list_files(file_name: "", file_ext: "")
        Dir[File.join(working_directory, self.team_id, "**", file_name, "*.#{file_ext}")]
      end

      # Implement this for the `fastlane match init` command
      # This method must return the content of the Matchfile
      # that should be generated
      def generate_matchfile_content(template: nil)
        project = UI.input("What is your GitLab Project (i.e. gitlab-org/gitlab): ")
        host = UI.input("What is your GitLab Host (i.e. https://gitlab.example.com, skip to default to https://gitlab.com): ")

        content = "gitlab_project(\"#{project}\")"

        content += "\ngitlab_host(\"#{host}\")" if host

        return content
      end
    end
  end
end
