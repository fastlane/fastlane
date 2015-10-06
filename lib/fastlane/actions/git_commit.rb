module Fastlane
  module Actions
    class GitCommitAction < Action
      def self.run(params)
        if params[:path].kind_of?(String)
          paths = "'#{params[:path]}'"
        else
          paths = params[:path].join(" ")
        end

        result = Actions.sh("git commit -m '#{params[:message]}' #{paths}")
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
                                       is_string: false,
                                       verify_block: proc do |value|
                                         if value.kind_of?(String)
                                           raise "Couldn't find file at path '#{value}'".red unless File.exist?(value)
                                         else
                                           value.each do |x|
                                             raise "Couldn't find file at path '#{x}'".red unless File.exist?(x)
                                           end
                                         end
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
