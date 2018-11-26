require_relative 'module'
require 'fileutils'

module Match
  class Migrate
    def migrate(args, options)
      params = FastlaneCore::Configuration.create(Match::Options.available_options, options.__hash__)
      params.load_configuration_file("Matchfile")

      ensure_parameters_are_valid(params)

      return unless UI.confirm("Right now, the migration tool only supports migrating from the git based storage to Google Cloud Storage. Sounds good?")

      git_storage = Storage.for_mode("git", {
        git_url: params[:git_url],
        shallow_clone: params[:shallow_clone],
        git_branch: params[:git_branch],
        clone_branch_directly: params[:clone_branch_directly]
      })
      git_storage.download

      encryption = Encryption.for_storage_mode(params[:storage_mode], {
        git_url: params[:git_url],
        working_directory: git_storage.working_directory
      })
      encryption.decrypt_files if encryption
      UI.success("Decrypted the git repo to '#{git_storage.working_directory}'")

      google_cloud_storage = Storage.for_mode("google_cloud", {
        google_cloud_bucket_name: params[:google_cloud_bucket_name].to_s
      })
      google_cloud_storage.download

      # Note how we always prefix the path in Google Cloud with the Team ID
      # while on Git we recommend using the git branch instead. As there is
      # no concept of branches in Google Cloud Storage (omg thanks), we use
      # the team id properly
      SpaceshipEnsure.new(params[:username], params[:team_id], params[:team_name])
      team_id = Spaceship.client.team_id
      UI.message("Detect team ID '#{team_id}' for Google Cloud Storage...")

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
      UI.success("Make sure to update your configuration to specify the `storage_mode`, as well as the bucket to use:")
      UI.message("")
      UI.command_output("\t\tstorage_mode \"google_cloud\"")
      UI.command_output("\t\tgoogle_cloud_bucket_name \"#{params[:google_cloud_bucket_name]}\"")
      UI.message("")
      UI.success("You can also remove the `git_url`, as well as any other git related configurations from your Fastfile and Matchfile")
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
