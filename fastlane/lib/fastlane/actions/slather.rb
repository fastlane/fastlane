module Fastlane
  module Actions
    module SharedValues
      SLATHER_CUSTOM_VALUE = :SLATHER_CUSTOM_VALUE
    end

    class SlatherAction < Action
      # https://github.com/SlatherOrg/slather/blob/v2.4.2/lib/slather/command/coverage_command.rb
      ARGS_MAP = {
          travis: '--travis',
          travis_pro: '--travispro',
          circleci: '--circleci',
          jenkins: '--jenkins',
          buildkite: '--buildkite',
          teamcity: '--teamcity',

          coveralls: '--coveralls',
          simple_output: '--simple-output',
          gutter_json: '--gutter-json',
          cobertura_xml: '--cobertura-xml',
          llvm_cov: '--llvm-cov',
          html: '--html',
          show: '--show',

          build_directory: '--build-directory',
          source_directory: '--source-directory',
          output_directory: '--output-directory',
          ignore: '--ignore',
          verbose: '--verbose',

          input_format: '--input-format',
          scheme: '--scheme',
          configuration: '--configuration',
          workspace: '--workspace',
          binary_file: '--binary-file',
          binary_basename: '--binary-basename',
          arch: '--arch',
          source_files: '--source-files',
          decimals: '--decimals'
      }.freeze

      def self.run(params)
        # This will fail if using Bundler. Skip the check rather than needing to
        # require bundler
        unless params[:use_bundle_exec]
          Actions.verify_gem!('slather')
        end

        validate_params!(params)

        command = build_command(params)
        sh(command)
      end

      def self.has_config_file
        File.file?('.slather.yml')
      end

      def self.slather_version
        require 'slather'
        Slather::VERSION
      end

      def self.configuration_available?
        Gem::Version.new('2.4.1') <= Gem::Version.new(slather_version)
      end

      def self.validate_params!(params)
        if params[:configuration]
          UI.user_error!('configuration option is available since version 2.4.1') unless configuration_available?
        end

        if params[:proj] || has_config_file
          true
        else
          UI.user_error!("You have to provide a project with `:proj` or use a .slather.yml")
        end
      end

      def self.build_command(params)
        command = []
        command.push("bundle exec") if params[:use_bundle_exec] && shell_out_should_use_bundle_exec?
        command << "slather coverage"

        ARGS_MAP.each do |key, cli_param|
          cli_value = params[key]
          if cli_value
            if cli_value.kind_of?(TrueClass)
              command << cli_param
            elsif cli_value.kind_of?(String)
              command << cli_param
              command << cli_value.shellescape
            elsif cli_value.kind_of?(Array)
              command << cli_value.map { |path| "#{cli_param} #{path.shellescape}" }
            end
          else
            next
          end
        end

        command << params[:proj].shellescape if params[:proj]
        command.join(" ")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Use slather to generate a code coverage report"
      end

      def self.details
        [
          "Slather works with multiple code coverage formats, including Xcode 7 code coverage.",
          "Slather is available at [https://github.com/SlatherOrg/slather](https://github.com/SlatherOrg/slather)."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :build_directory,
                                       env_name: "FL_SLATHER_BUILD_DIRECTORY", # The name of the environment variable
                                       description: "The location of the build output", # a short description of this parameter
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :proj,
                                       env_name: "FL_SLATHER_PROJ", # The name of the environment variable
                                       description: "The project file that slather looks at", # a short description of this parameter
                                       verify_block: proc do |value|
                                         UI.user_error!("No project file specified, pass using `proj: 'Project.xcodeproj'`") unless value && !value.empty?
                                       end,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :workspace,
                                       env_name: "FL_SLATHER_WORKSPACE",
                                       description: "The workspace that slather looks at",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :scheme,
                                       env_name: "FL_SLATHER_SCHEME", # The name of the environment variable
                                       description: "Scheme to use when calling slather",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :configuration,
                                       env_name: "FL_SLATHER_CONFIGURATION", # The name of the environment variable
                                       description: "Configuration to use when calling slather (since slather-2.4.1)",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :input_format,
                                       env_name: "FL_SLATHER_INPUT_FORMAT", # The name of the environment variable
                                       description: "The input format that slather should look for",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :buildkite,
                                       env_name: "FL_SLATHER_BUILDKITE_ENABLED", # The name of the environment variable
                                       description: "Tell slather that it is running on Buildkite",
                                       is_string: false,
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :teamcity,
                                       env_name: "FL_SLATHER_TEAMCITY_ENABLED", # The name of the environment variable
                                       description: "Tell slather that it is running on TeamCity",
                                       is_string: false,
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :jenkins,
                                       env_name: "FL_SLATHER_JENKINS_ENABLED", # The name of the environment variable
                                       description: "Tell slather that it is running on Jenkins",
                                       is_string: false,
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :travis,
                                       env_name: "FL_SLATHER_TRAVIS_ENABLED", # The name of the environment variable
                                       description: "Tell slather that it is running on TravisCI",
                                       is_string: false,
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :travis_pro,
                                       env_name: "FL_SLATHER_TRAVIS_PRO_ENABLED", # The name of the environment variable
                                       description: "Tell slather that it is running on TravisCI Pro",
                                       is_string: false,
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :circleci,
                                       env_name: "FL_SLATHER_CIRCLECI_ENABLED",
                                       description: "Tell slather that it is running on CircleCI",
                                       is_string: false,
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :coveralls,
                                       env_name: "FL_SLATHER_COVERALLS_ENABLED",
                                       description: "Tell slather that it should post data to Coveralls",
                                       is_string: false,
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :simple_output,
                                       env_name: "FL_SLATHER_SIMPLE_OUTPUT_ENABLED",
                                       description: "Tell slather that it should output results to the terminal",
                                       is_string: false,
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :gutter_json,
                                       env_name: "FL_SLATHER_GUTTER_JSON_ENABLED",
                                       description: "Tell slather that it should output results as Gutter JSON format",
                                       is_string: false,
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :cobertura_xml,
                                       env_name: "FL_SLATHER_COBERTURA_XML_ENABLED",
                                       description: "Tell slather that it should output results as Cobertura XML format",
                                       is_string: false,
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :llvm_cov,
                                       env_name: "FL_SLATHER_LLVM_COV_ENABLED",
                                       description: "Tell slather that it should output results as llvm-cov show format",
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :html,
                                       env_name: "FL_SLATHER_HTML_ENABLED",
                                       description: "Tell slather that it should output results as static HTML pages",
                                       is_string: false,
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :show,
                                       env_name: "FL_SLATHER_SHOW_ENABLED",
                                       description: "Tell slather that it should open static html pages automatically",
                                       is_string: false,
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :source_directory,
                                       env_name: "FL_SLATHER_SOURCE_DIRECTORY",
                                       description: "Tell slather the location of your source files",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :output_directory,
                                       env_name: "FL_SLATHER_OUTPUT_DIRECTORY",
                                       description: "Tell slather the location of for your output files",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :ignore,
                                       env_name: "FL_SLATHER_IGNORE",
                                       description: "Tell slather to ignore files matching a path or any path from an array of paths",
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_SLATHER_VERBOSE",
                                       description: "Tell slather to enable verbose mode",
                                       is_string: false,
                                       type: Boolean,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :use_bundle_exec,
                                      env_name: "FL_SLATHER_USE_BUNDLE_EXEC",
                                      description: "Use bundle exec to execute slather. Make sure it is in the Gemfile",
                                      is_string: false,
                                      type: Boolean,
                                      default_value: false),
          FastlaneCore::ConfigItem.new(key: :binary_basename,
                                       env_name: "FL_SLATHER_BINARY_BASENAME",
                                       description: "Basename of the binary file, this should match the name of your bundle excluding its extension (i.e. YourApp [for YourApp.app bundle])",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :binary_file,
                                       env_name: "FL_SLATHER_BINARY_FILE",
                                       description: "Binary file name to be used for code coverage",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :arch,
                                       env_name: "FL_SLATHER_ARCH",
                                       description: "Specify which architecture the binary file is in. Needed for universal binaries",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :source_files,
                                       env_name: "FL_SLATHER_SOURCE_FILES",
                                       description: "A Dir.glob compatible pattern used to limit the lookup to specific source files. Ignored in gcov mode",
                                       is_string: false,
                                       default_value: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :decimals,
                                      env_name: "FL_SLATHER_DECIMALS",
                                      description: "The amount of decimals to use for % coverage reporting",
                                      is_string: false,
                                      default_value: false,
                                      optional: true)
        ]
      end

      def self.output
      end

      def self.authors
        ["mattdelves"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'slather(
            build_directory: "foo",
            input_format: "bah",
            scheme: "MyScheme",
            proj: "MyProject.xcodeproj"
          )'
        ]
      end

      def self.category
        :testing
      end
    end
  end
end
