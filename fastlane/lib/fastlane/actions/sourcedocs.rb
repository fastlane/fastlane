module Fastlane
  module Actions
    class SourceDocsAction < Action
      def self.run(params)
        if `which sourcedocs`.to_s.length == 0
          UI.user_error!("You have to install sourcedocs using `brew install sourcedocs")
        end
        command = "sourcedocs generate"
        command << " --reproducible-docs #{params[:reproducible]}" if params[:reproducible]
        command << ['-o', "\"#{params[:output]}\""]
        command << " --clean #{params[:clean]}" if params[:clean]
        command << params[:frameworks].map { |scheme| ['-- -scheme', "\"#{scheme}\""] }.flatten if params[:scheme]
        Actions.sh(command)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Generate docs using SourceDocs"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :reproducible,
            env_name: 'FL_SOURCEDOCS_REPRODUCIBLE',
            description: 'Generate documentation that is reproducible: only depends on the sources',
            type: Boolean,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :output,
            env_name: 'FL_SOURCEDOCS_OUTPUT',
            description: 'Path to write docs to',
            type: String,
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :clean,
            env_name: 'FL_SOURCEDOCS_CLEAN',
            description: 'Delete output folder before generating documentation',
            type: Boolean,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :scheme,
            env_name: 'FL_SOURCEDOCS_SCHEME',
            description: 'Create documentation for specific scheme',
            type: String,
            optional: true
          )
        ]
      end

      def self.output
      end

      def self.return_value
      end

      def self.authors
        ["Kukurijek"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          "sourcedocs(output: 'docs')",
          "sourcedocs(output: 'docs', scheme: 'MyApp')"
        ]
      end

      def self.category
        :documentation
      end
    end
  end
end
