module Fastlane
  module Actions
    class SonarAction < Action
      def self.run(params)
        verify_sonar_scanner_binary

        scanner_args = []
        scanner_args << 'sonar-scanner'
        scanner_args << "-Dproject.settings=\"#{params[:project_configuration_path]}\"" if params[:project_configuration_path]
        scanner_args << "-Dsonar.projectKey=\"#{params[:project_key]}\"" if params[:project_key]
        scanner_args << "-Dsonar.projectName=\"#{params[:project_name]}\"" if params[:project_name]
        scanner_args << "-Dsonar.projectVersion=\"#{params[:project_version]}\"" if params[:project_version]
        scanner_args << "-Dsonar.sources=\"#{params[:sources_path]}\"" if params[:sources_path]
        scanner_args << "-Dsonar.language=\"#{params[:project_language]}\"" if params[:project_language]
        scanner_args << "-Dsonar.sourceEncoding=\"#{params[:source_encoding]}\"" if params[:source_encoding]
        scanner_args << "-Dsonar.login=\"#{params[:sonar_login]}\"" if params[:sonar_login]
        scanner_args << params[:sonar_runner_args] if params[:sonar_runner_args]

        command = scanner_args.join(' ')

        # hide command, as it may contain credentials
        Fastlane::Actions.sh_control_output(command, print_command: false, print_command_output: params[:verbose])
      end

      def self.verify_sonar_scanner_binary
        UI.user_error!("You have to install sonar-scanner using `brew install sonar-scanner`") unless `which sonar-scanner`.to_s.length > 0
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Invokes sonar-scanner to run SonarQube analysis in the project workspace"
      end

      def self.details
        [
          "See http://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Scanner for details.",
          "Parameters can be specified from this action or inside the sonar project configuration file",
          "The command will never be printed to the console as it may contain login information"
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :project_configuration_path,
                                        env_name: "FL_SONAR_RUNNER_PROPERTIES_PATH",
                                        description: "The path to your sonar project configuration file; defaults to `sonar-project.properties`", # default is enforced by sonar-scanner binary
                                        optional: true,
                                        verify_block: proc do |value|
                                          UI.user_error!("Couldn't find file at path '#{value}'") unless value.nil? || File.exist?(value)
                                        end),
          FastlaneCore::ConfigItem.new(key: :project_key,
                                       env_name: "FL_SONAR_RUNNER_PROJECT_KEY",
                                       description: "The key sonar uses to identify the project, e.g. `name.gretzki.awesomeApp`",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :project_name,
                                       env_name: "FL_SONAR_RUNNER_PROJECT_NAME",
                                       description: "The name of the project that gets displayed on the sonar report page",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :project_version,
                                       env_name: "FL_SONAR_RUNNER_PROJECT_VERSION",
                                       description: "The project's version that gets displayed on the sonar report page",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :sources_path,
                                       env_name: "FL_SONAR_RUNNER_SOURCES_PATH",
                                       description: "Comma-separated paths to directories containing source files",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :project_language,
                                       env_name: "FL_SONAR_RUNNER_PROJECT_LANGUAGE",
                                       description: "Language key, e.g. objc",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :source_encoding,
                                       env_name: "FL_SONAR_RUNNER_SOURCE_ENCODING",
                                       description: "Used encoding of source files, e.g., UTF-8",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :sonar_runner_args,
                                       env_name: "FL_SONAR_RUNNER_ARGS",
                                       description: "Pass additional arguments. Be sure to provide the arguments with a leading `-D` e.g. FL_SONAR_RUNNER_ARGS=\"-Dsonar.log.level=DEBUG\"",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :sonar_login,
                                       env_name: "FL_SONAR_LOGIN",
                                       description: "Pass the Sonar Login token (e.g: xxxxxxprivate_token_XXXXbXX7e)",
                                       optional: true,
                                       is_string: true,
                                       sensitive: true),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_SONAR_VERBOSE",
                                       description: "Print any form of output from sonar-scanner",
                                       is_string: false,
                                       default_value: true)
        ]
      end

      def self.return_value
        "The exit code of the sonar-scanner binary"
      end

      def self.authors
        ["c_gretzki", "petrosichor"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'sonar(
            project_key: "name.gretzki.awesomeApp",
            project_version: "1.0",
            project_name: "iOS - AwesomeApp",
            sources_path: File.expand_path("../AwesomeApp"),
            verbose: false
          )'
        ]
      end

      def self.category
        :testing
      end
    end
  end
end
