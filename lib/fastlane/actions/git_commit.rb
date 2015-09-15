module Fastlane
  module Actions
    class GitCommitAction < Action
      def self.run(params)
        result = Actions.sh("git commit -m '#{params[:message]}' '#{params[:path]}'")
        Helper.log.info "Successfully committed \"#{params[:path]}\" 💾.".green
        return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Directly commit the given file with the given message"
      end

      def self.details
        ""
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       description: "The file you want to commit",
                                       verify_block: proc do |value|
                                         raise "Couldn't find file at path '#{value}'".red unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :message,
                                       description: "The commit message that should be used")
        ]
      end

      def self.output
      end

      def self.return_value
        nil
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
