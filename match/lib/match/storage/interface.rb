require_relative '../module'

module Match
  module Storage
    class Interface
      MATCH_VERSION_FILE_NAME = "match_version.txt"

      # The working directory in which we download all the profiles
      # and decrypt/encrypt them
      attr_accessor :working_directory

      # To make debugging easier, we have a custom exception here
      def working_directory
        if @working_directory.nil?
          raise "`working_directory` for the current storage provider is `nil` as the `#download` method was never called"
        end
        return @working_directory
      end

      # Call this method after creating a new object to configure
      # the given Storage object. This method will take
      # different paramters depending on specific class being used
      def configure
        not_implemented(__method__)
      end

      # Call this method for the initial clone/download of the
      # user's certificates & profiles
      # As part of this method, the `self.working_directory` attribute
      # will be set
      def download
        not_implemented(__method__)
      end

      # Call this method after locally modifying the files
      # This will commit the changes and push it back to the
      # given remote server
      # This method is blocking, meaning it might take multiple
      # seconds or longer to run
      # @parameter files_to_commit [Array] Array to paths to files
      #   that should be committed to the storage provider
      # @parameter custom_message: [String] Custom change message
      #           that's optional, is used for commit title
      def save_changes!(files_to_commit: [], files_to_delete: [], custom_message: nil)
        Dir.chdir(File.expand_path(self.working_directory)) do
          if files_to_commit.count > 0 # everything that isn't `match nuke`
            UI.user_error!("You can't provide both `files_to_delete` and `files_to_commit` right now") if files_to_delete.count > 0

            if !File.exist?(MATCH_VERSION_FILE_NAME) || File.read(MATCH_VERSION_FILE_NAME) != Fastlane::VERSION.to_s
              files_to_commit << MATCH_VERSION_FILE_NAME
              File.write(MATCH_VERSION_FILE_NAME, Fastlane::VERSION) # stored unencrypted
            end

            template = File.read("#{Match::ROOT}/lib/assets/READMETemplate.md")
            readme_path = "README.md"
            if (!File.exist?(readme_path) || File.read(readme_path) != template) && !self.skip_docs
              files_to_commit << readme_path
              File.write(readme_path, template)
            end

            self.upload_files(files_to_upload: files_to_commit, custom_message: custom_message)
          elsif files_to_delete.count > 0
            self.delete_files(files_to_delete: files_to_delete, custom_message: custom_message)
          else
            UI.user_error!("Neither `files_to_commit` nor `files_to_delete` were provided to the `save_changes!` method call")
          end
        end
      end

      def upload_files(files_to_upload: [], custom_message: nil)
        not_implemented(__method__)
      end

      def delete_files(files_to_delete: [], custom_message: nil)
        not_implemented(__method__)
      end

      def skip_docs
        not_implemented(__method__)
      end

      # Call this method to reset any changes made locally to the files
      def clear_changes
        not_implemented(__method__)
      end
    end
  end
end
