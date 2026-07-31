require_relative 'spaceship_ensure'
require_relative 'encryption'
require_relative 'storage'
require_relative 'module'
require 'fileutils'

module Match
  class Migrate
    def migrate(params)
      loaded_matchfile = params.load_configuration_file("Matchfile")

      ensure_parameters_are_valid(params)

      # We init the Google storage client before the git client
      # to ask for all the missing inputs *before* cloning the git repo
      google_cloud_storage = Storage.from_params({
        storage_mode: "google_cloud",
        google_cloud_bucket_name: params[:google_cloud_bucket_name],
        google_cloud_keys_file: params[:google_cloud_keys_file],
        google_cloud_project_id: params[:google_cloud_project_id]
      })

      git_storage = Storage.from_params({
        storage_mode: "git",
        git_url: params[:git_url],
        shallow_clone: params[:shallow_clone],
        git_branch: params[:git_branch],
        clone_branch_directly: params[:clone_branch_directly]
      })
      git_storage.download

      encryption = Encryption.for_storage_mode(params[:storage_mode], {
        git_url: params[:git_url],
        s3_bucket: params[:s3_bucket],
        s3_skip_encryption: params[:s3_skip_encryption],
        working_directory: git_storage.working_directory
      })
      encryption.decrypt_files if encryption
      UI.success("Decrypted the git repo to '#{git_storage.working_directory}'")

      google_cloud_storage.download

      # Note how we always prefix the path in Google Cloud with the Team ID
      # while on Git we recommend using the git branch instead. As there is
      # no concept of branches in Google Cloud Storage (omg thanks), we use
      # the team id properly
      spaceship = SpaceshipEnsure.new(params[:username], params[:team_id], params[:team_name], api_token(params))
      team_id = spaceship.team_id

      if team_id.to_s.empty?
        UI.user_error!("The `team_id` option is required. fastlane cannot automatically determine portal team id via the App Store Connect API (yet)")
      else
        UI.message("Detected team ID '#{team_id}' to use for Google Cloud Storage...")
      end

      files_to_commit = []
      Dir.chdir(git_storage.working_directory) do
        Dir[File.join("**", "*")].each do |current_file|
          next if File.directory?(current_file)

          to_path = File.join(google_cloud_storage.working_directory, team_id, current_file)
          FileUtils.mkdir_p(File.expand_path("..", to_path))

          if File.exist?(to_path)
            UI.user_error!("Looks like file already exists on Google Cloud Storage at path '#{to_path}', stopping the migration process. Please make sure the bucket is empty, or at least doesn't contain any files related to the same Team ID")
          end
          FileUtils.cp(current_file, to_path)

          files_to_commit << to_path
        end
      end

      google_cloud_storage.save_changes!(files_to_commit: files_to_commit)

      UI.success("Successfully migrated your code signing certificates and provisioning profiles to Google Cloud Storage")
      UI.success("Make sure to update your configuration to specify the `storage_mode`, as well as the bucket to use.")
      UI.message("")
      if loaded_matchfile
        UI.message("Update your Matchfile at path '#{loaded_matchfile.configfile_path}':")
        UI.message("")
        UI.command_output("\t\tstorage_mode \"google_cloud\"")
        UI.command_output("\t\tgoogle_cloud_bucket_name \"#{google_cloud_storage.bucket_name}\"")
      else
        UI.message("Update your Fastfile `match` call to include")
        UI.message("")
        UI.command_output("\t\tstorage_mode: \"google_cloud\",")
        UI.command_output("\t\tgoogle_cloud_bucket_name: \"#{google_cloud_storage.bucket_name}\",")
      end
      UI.message("")
      UI.success("You can also remove the `git_url`, as well as any other git related configurations from your Fastfile and Matchfile")
      UI.message("")
      UI.input("Please make sure to read the above and confirm with enter")
    ensure
      google_cloud_storage.clear_changes if google_cloud_storage
      git_storage.clear_changes if git_storage
    end

    def api_token(params)
      api_token = Spaceship::ConnectAPI::Token.from(hash: params[:api_key], filepath: params[:api_key_path])
      return api_token
    end

    def ensure_parameters_are_valid(params)
      if params[:readonly]
        UI.user_error!("`fastlane match migrate` doesn't work in `readonly` mode")
      end

      if params[:storage_mode] != "git"
        UI.user_error!("`fastlane match migrate` only allows migration from `git` to `google_cloud` right now, looks like your currently selected `storage_mode` is '#{params[:storage_mode]}'")
      end
    end
  end
end
