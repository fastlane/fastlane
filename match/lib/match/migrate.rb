require_relative 'module'
require 'fileutils'

module Match
  class Migrate
    def migrate(args, options)
      params = FastlaneCore::Configuration.create(Match::Options.available_options, options.__hash__)
      params.load_configuration_file("Matchfile")

      ensure_parameters_are_valid(params)
      ask_for_missing_user_inputs(params)

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
        google_cloud_bucket_name: params[:google_cloud_bucket_name],
        google_cloud_keys_file: params[:google_cloud_keys_file]
      })
      google_cloud_storage.download

      # Note how we always prefix the path in Google Cloud with the Team ID
      # while on Git we recommend using the git branch instead. As there is
      # no concept of branches in Google Cloud Storage (omg thanks), we use
      # the team id properly
      SpaceshipEnsure.new(params[:username], params[:team_id], params[:team_name])
      team_id = Spaceship.client.team_id
      UI.message("Detected team ID '#{team_id}' to use for Google Cloud Storage...")

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

    # TODO: those shouldn't be part of `match migrate`
    def ask_for_missing_user_inputs(params)
      if params[:google_cloud_keys_file].to_s.length == 0
        if File.exist?("gc_keys.json")
          params[:google_cloud_keys_file] = "gc_keys.json"
        else
          UI.message("Looks like you don't have a Google Cloud " + "gc_keys.json".cyan + " file yet")
          UI.message("fastlane will help you create one. First, open the following website")
          UI.message("\t\thttps://console.cloud.google.com".cyan)
          UI.message("")
          UI.input("Press enter once you're logged in")
          
          UI.message("Now it's time to generate a new JSON auth file for fastlane to access Google Cloud")
          UI.message("First, switch to the Google Cloud project you want to use.")
          UI.message("If you don't have one yet, create a new one and switch to it")
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
          UI.message("and rename it to `" + "gc_keys.json".cyan + "`")
          UI.message("")
          UI.input("Confirm with enter")

          # TODO: Put the name into a constant
          while !File.exist?("gc_keys.json")
            UI.message("Make sure to place the file in #{Dir.pwd} and name it `gc_keys.json`")
            UI.input("Confirm with enter")
          end
          params[:google_cloud_keys_file] = "gc_keys.json"
        end
      end
    end
  end
end
