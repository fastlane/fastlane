module Match
  module Storage
    class Interface
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
      def save_changes!(files_to_commit: [], custom_message: nil)
        not_implemented(__method__)
      end

      # Call this method to reset any changes made locally to the files
      def clear_changes
        not_implemented(__method__)
      end
    end
  end
end
