module Fastlane
  module Actions
    module SharedValues
      SVN_COMMIT_CUSTOM_VALUE = :SVN_COMMIT_CUSTOM_VALUE
    end

    class SvnCommitAction < Action
      def self.run(params)
        if params[:path].kind_of?(String)
          paths = params[:path].shellescape
        else
          paths = params[:path].map(&:shellescape).join(' ')
        end

        result = Actions.sh("svn commit -m #{params[:message].shellescape} #{paths}")
        UI.success("Successfully committed.")
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
                                           UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                         else
                                           value.each do |x|
                                             UI.user_error!("Couldn't find file at path '#{x}'") unless File.exist?(x)
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
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["cleexiang"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.category
        :source_control
      end
    end
  end
end
