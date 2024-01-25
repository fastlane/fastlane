require_relative '../module'

module Match
  module Storage
    class Interface
      MATCH_VERSION_FILE_NAME = "match_version.txt"
      # The working directory in which we download all the profiles
      # and decrypt/encrypt them
      attr_accessor :working_directory

      # To make debugging easier, we have a custom exception here
      def prefixed_working_directory
        not_implemented(__method__)
      end

      # To make debugging easier, we have a custom exception here
      def working_directory
        if @working_directory.nil?
          raise "`working_directory` for the current storage provider is `nil` as the `#download` method was never called"
        end
        return @working_directory
      end

      # Call this method after creating a new object to configure
      # the given Storage object. This method will take
      # different parameters depending on specific class being used
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

      # Returns a short string describing + identifying the current
      # storage backend. This will be printed when nuking a storage
      def human_readable_description
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
      def save_changes!(files_to_commit: nil, files_to_delete: nil, custom_message: nil)
        # Custom init to `[]` in case `nil` is passed
        files_to_commit ||= []
        files_to_delete ||= []
        files_to_delete -= files_to_commit # Make sure we are not removing added files.

        if files_to_commit.count == 0 && files_to_delete.count == 0
          UI.user_error!("Neither `files_to_commit` nor `files_to_delete` were provided to the `save_changes!` method call")
        end

        Dir.chdir(File.expand_path(self.working_directory)) do
          if files_to_commit.count > 0 # everything that isn't `match nuke`
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
            UI.message("Finished uploading files to #{self.human_readable_description}")
          end

          if files_to_delete.count > 0
            self.delete_files(files_to_delete: files_to_delete, custom_message: custom_message)
            UI.message("Finished deleting files from #{self.human_readable_description}")
          end
        end
      ensure # Always clear working_directory after save
        self.clear_changes
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

      def list_files(file_name: "", file_ext: "")
        not_implemented(__method__)
      end

      # Implement this for the `fastlane match init` command
      # This method must return the content of the Matchfile
      # that should be generated
      def generate_matchfile_content(template: nil)
        not_implemented(__method__)
      end

      # Call this method to reset any changes made locally to the files
      def clear_changes
        return unless @working_directory

        FileUtils.rm_rf(self.working_directory)
        self.working_directory = nil
      end
    end
  end
end
