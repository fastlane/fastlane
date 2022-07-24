module Fastlane
  module Actions
    class SourcedocsAction < Action
      def self.run(params)
        UI.user_error!("You have to install sourcedocs using `brew install sourcedocs`") if `which sourcedocs`.to_s.length == 0 && !Helper.test?

        command =  "sourcedocs generate"
        command << " --all-modules" if params[:all_modules]
        command << " --spm-module #{params[:spm_module]}" unless params[:spm_module].nil?
        command << " --module-name #{params[:module_name]}" unless params[:module_name].nil?
        command << " --link-beginning #{params[:link_beginning]}" unless params[:link_beginning].nil?
        command << " --link-ending #{params[:link_ending]}" unless params[:link_ending].nil?
        command << " --output-folder #{params[:output_folder]}" unless params[:output_folder].nil?
        command << " --min-acl #{params[:min_acl]}" unless params[:min_acl].nil?
        command << " --module-name-path" if params[:module_name_path]
        command << " --clean" if params[:clean]
        command << " --collapsible" if params[:collapsible]
        command << " --table-of-contents" if params[:table_of_contents]
        command << " --reproducible-docs" if params[:reproducible]
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
          FastlaneCore::ConfigItem.new(key: :all_modules,
                                       env_name: 'FL_SOURCEDOCS_OUTPUT_ALL_MODULES',
                                       description: 'Generate documentation for all modules in a Swift package',
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :spm_module,
                                       env_name: 'FL_SOURCEDOCS_SPM_MODULE',
                                       description: 'Generate documentation for Swift Package Manager module',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :module_name,
                                       env_name: 'FL_SOURCEDOCS_MODULE_NAME',
                                       description: 'Generate documentation for a Swift module',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :link_beginning,
                                       env_name: 'FL_SOURCEDOCS_LINK_BEGINNING',
                                       description: 'The text to begin links with',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :link_ending,
                                       env_name: 'FL_SOURCEDOCS_LINK_ENDING',
                                       description: 'The text to end links with (default: .md)',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :output_folder,
                                       env_name: 'FL_SOURCEDOCS_OUTPUT_FOLDER',
                                       description: 'Output directory to clean (default: Documentation/Reference)',
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :min_acl,
                                       env_name: 'FL_SOURCEDOCS_MIN_ACL',
                                       description: 'Access level to include in documentation [private, fileprivate, internal, public, open] (default: public)',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :module_name_path,
                                       env_name: 'FL_SOURCEDOCS_MODULE_NAME_PATH',
                                       description: 'Include the module name as part of the output folder path',
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :clean,
                                       env_name: 'FL_SOURCEDOCS_CLEAN',
                                       description: 'Delete output folder before generating documentation',
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :collapsible,
                                       env_name: 'FL_SOURCEDOCS_COLLAPSIBLE',
                                       description: 'Put methods, properties and enum cases inside collapsible blocks',
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :table_of_contents,
                                       env_name: 'FL_SOURCEDOCS_TABLE_OF_CONTENT',
                                       description: 'Generate a table of contents with properties and methods for each type',
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :reproducible,
                                       env_name: 'FL_SOURCEDOCS_REPRODUCIBLE',
                                       description: 'Generate documentation that is reproducible: only depends on the sources',
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :scheme,
                                       env_name: 'FL_SOURCEDOCS_SCHEME',
                                       description: 'Create documentation for specific scheme',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :sdk_platform,
                                       env_name: 'FL_SOURCEDOCS_SDK_PlATFORM',
                                       description: 'Create documentation for specific sdk platform',
                                       optional: true)
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
          "sourcedocs(output_folder: 'docs')",
          "sourcedocs(output_folder: 'docs', clean: true, reproducible: true, scheme: 'MyApp')"
        ]
      end

      def self.category
        :documentation
      end
    end
  end
end
