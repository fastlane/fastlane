module Fastlane
  module Actions
    class SourcedocsAction < Action
      def self.run(params)
        UI.user_error!("You have to install sourcedocs using `brew install sourcedocs`") if `which sourcedocs`.to_s.length == 0

        command =  "sourcedocs generate"
        command << " --reproducible-docs" if params[:reproducible]
        command << " -o #{params[:output]}"
        command << " --clean" if params[:clean]
        unless params[:scheme].nil?
          command << " -- -scheme #{params[:scheme]}"
          command << " -sdk #{params[:sdk_platform]}" unless params[:sdk_platform].nil?
        end
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
          ),
          FastlaneCore::ConfigItem.new(
            key: :sdk_platform,
            env_name: 'FL_SOURCEDOCS_SDK_PlATFORM',
            description: 'Create documentation for specific sdk platform',
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
