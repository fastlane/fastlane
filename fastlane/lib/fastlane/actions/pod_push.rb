module Fastlane
  module Actions
    class PodPushAction < Action
      def self.run(params)
        if params[:repo]
          repo = params[:repo]
          command = "pod repo push #{repo}"
        else
          command = 'pod trunk push'
        end

        if params[:path]
          command << " '#{params[:path]}'"
        end

        if params[:sources]
          sources = params[:sources].join(",")
          command << " --sources='#{sources}'"
        end

        if params[:allow_warnings]
          command << " --allow-warnings"
        end

        result = Actions.sh(command.to_s)
        Helper.log.info "Successfully pushed Podspec ⬆️ ".green
        return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Push a Podspec to Trunk or a private repository"
      end

      def self.details
        ""
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       description: "The Podspec you want to push",
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Couldn't find file at path '#{value}'".red unless File.exist?(value)
                                         raise "File must be a `.podspec`".red unless value.end_with?(".podspec")
                                       end),
          FastlaneCore::ConfigItem.new(key: :repo,
                                       description: "The repo you want to push. Pushes to Trunk by default",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :allow_warnings,
                                       description: "Allow warnings during pod push",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :sources,
                                       description: "The sources of repos you want the pod spec to lint with, separated by commas",
                                       optional: true,
                                       is_string: false,
                                       verify_block: proc do |value|
                                         raise "Sources must be an array.".red unless value.kind_of?(Array)
                                       end)
        ]
      end

      def self.output
      end

      def self.return_value
        nil
      end

      def self.authors
        ["squarefrog"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
