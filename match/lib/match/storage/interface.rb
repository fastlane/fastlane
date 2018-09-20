module Match
  module Storage
    class Interface
      def initialize
        not_implemented(__method__)
      end

      # Call this method after creating a new object to configure
      # the given Storage object. This method will take
      # different paramters depending on specific class being used
      def configure
        not_implemented(__method__)
      end

      # Call this method for the initial clone/download of the
      # user's certificates & profiles
      def download
        not_implemented(__method__)
      end

      # Call this method after locally modifying the files
      # This will commit the changes and push it back to the
      # given remote server
      # This method is blocking, meaning it might take multiple
      # seconds or longer to run
      def save_changes!
        not_implemented(__method__)
      end

      # TODO: what is this method used for exactly
      # and how should it behave
      def clear_changes
        not_implemented(__method__)
      end
    end
  end
end
