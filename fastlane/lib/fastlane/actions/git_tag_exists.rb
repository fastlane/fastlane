module Fastlane
  module Actions
    class GitTagExistsAction < Action
      def self.run(params)
        result = Actions.sh("git rev-parse -q --verify refs/tags/#{params[:tag].shellescape} || true", log: $verbose).chomp
        !result.empty?
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Checks if the git tag with the given name exists in the current repo"
      end

      def self.details
        nil
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :tag,
                                       description: "The tag name that should be checked")
        ]
      end

      def self.output
        [
          "Outputs the hash of the given tag if exists otherwise outputs nil"
        ]
      end

      def self.authors
        ["antondomashnev"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
