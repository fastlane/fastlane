module Fastlane
  module Actions
    class SonarAction < Action
      def self.run(params)
        verify_sonar_scanner_binary

        command_prefix = [
          'cd',
          File.expand_path('.').shellescape,
          '&&'
        ].join(' ')

        sonar_scanner_args = []
        sonar_scanner_args << "-Dproject.settings=\"#{params[:project_configuration_path]}\"" if params[:project_configuration_path]
        sonar_scanner_args << "-Dsonar.projectKey=\"#{params[:project_key]}\"" if params[:project_key]
        sonar_scanner_args << "-Dsonar.projectName=\"#{params[:project_name]}\"" if params[:project_name]
        sonar_scanner_args << "-Dsonar.projectVersion=\"#{params[:project_version]}\"" if params[:project_version]
        sonar_scanner_args << "-Dsonar.sources=\"#{params[:sources_path]}\"" if params[:sources_path]
        sonar_scanner_args << "-Dsonar.exclusions=\"#{params[:exclusions]}\"" if params[:exclusions]
        sonar_scanner_args << "-Dsonar.language=\"#{params[:project_language]}\"" if params[:project_language]
        sonar_scanner_args << "-Dsonar.sourceEncoding=\"#{params[:source_encoding]}\"" if params[:source_encoding]
        sonar_scanner_args << "-Dsonar.login=\"#{params[:sonar_login]}\"" if params[:sonar_login]
        sonar_scanner_args << "-Dsonar.token=\"#{params[:sonar_token]}\"" if params[:sonar_token]
        sonar_scanner_args << "-Dsonar.host.url=\"#{params[:sonar_url]}\"" if params[:sonar_url]
        sonar_scanner_args << "-Dsonar.organization=\"#{params[:sonar_organization]}\"" if params[:sonar_organization]
        sonar_scanner_args << "-Dsonar.branch.name=\"#{params[:branch_name]}\"" if params[:branch_name]
        sonar_scanner_args << "-Dsonar.pullrequest.branch=\"#{params[:pull_request_branch]}\"" if params[:pull_request_branch]
        sonar_scanner_args << "-Dsonar.pullrequest.base=\"#{params[:pull_request_base]}\"" if params[:pull_request_base]
        sonar_scanner_args << "-Dsonar.pullrequest.key=\"#{params[:pull_request_key]}\"" if params[:pull_request_key]

        sonar_scanner_args << params[:sonar_runner_args] if params[:sonar_runner_args]

        command = [
          command_prefix,
          'sonar-scanner',
          sonar_scanner_args
        ].join(' ')
        # hide command, as it may contain credentials
        Fastlane::Actions.sh_control_output(command, print_command: false, print_command_output: true)
      end

      def self.verify_sonar_scanner_binary
        UI.user_error!("You have to install sonar-scanner using `brew install sonar-scanner`") unless `which sonar-scanner`.to_s.length > 0
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Invokes sonar-scanner to programmatically run SonarQube analysis"
      end

      def self.details
        [
          "See [http://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Scanner](http://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Scanner) for details.",
          "It can process unit test results if formatted as junit report as shown in [xctest](https://docs.fastlane.tools/actions/xctest/) action. It can also integrate coverage reports in Cobertura format, which can be transformed into by the [slather](https://docs.fastlane.tools/actions/slather/) action."
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
                                       description: "The key sonar uses to identify the project, e.g. `name.gretzki.awesomeApp`. Must either be specified here or inside the sonar project configuration file",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :project_name,
                                       env_name: "FL_SONAR_RUNNER_PROJECT_NAME",
                                       description: "The name of the project that gets displayed on the sonar report page. Must either be specified here or inside the sonar project configuration file",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :project_version,
                                       env_name: "FL_SONAR_RUNNER_PROJECT_VERSION",
                                       description: "The project's version that gets displayed on the sonar report page. Must either be specified here or inside the sonar project configuration file",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :sources_path,
                                       env_name: "FL_SONAR_RUNNER_SOURCES_PATH",
                                       description: "Comma-separated paths to directories containing source files. Must either be specified here or inside the sonar project configuration file",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :exclusions,
                                       env_name: "FL_SONAR_RUNNER_EXCLUSIONS",
                                       description: "Comma-separated paths to directories to be excluded from the analysis",
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
                                       description: "Pass additional arguments to sonar-scanner. Be sure to provide the arguments with a leading `-D` e.g. FL_SONAR_RUNNER_ARGS=\"-Dsonar.verbose=true\"",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :sonar_login,
                                       env_name: "FL_SONAR_LOGIN",
                                       description: "Pass the Sonar Login Token (e.g: xxxxxxprivate_token_XXXXbXX7e)",
                                       deprecated: "Login and password were deprecated in favor of login token. See https://community.sonarsource.com/t/deprecating-sonar-login-and-sonar-password-in-favor-of-sonar-token/95829 for more details",
                                       optional: true,
                                       sensitive: true,
                                       conflicting_options: [:sonar_token]),
          FastlaneCore::ConfigItem.new(key: :sonar_token,
                                       env_name: "FL_SONAR_TOKEN",
                                       description: "Pass the Sonar Token (e.g: xxxxxxprivate_token_XXXXbXX7e)",
                                       optional: true,
                                       sensitive: true,
                                       conflicting_options: [:sonar_login]),
          FastlaneCore::ConfigItem.new(key: :sonar_url,
                                       env_name: "FL_SONAR_URL",
                                       description: "Pass the url of the Sonar server",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :sonar_organization,
                                       env_name: "FL_SONAR_ORGANIZATION",
                                       description: "Key of the organization on SonarCloud",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :branch_name,
                                       env_name: "FL_SONAR_RUNNER_BRANCH_NAME",
                                       description: "Pass the branch name which is getting scanned",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :pull_request_branch,
                                       env_name: "FL_SONAR_RUNNER_PULL_REQUEST_BRANCH",
                                       description: "The name of the branch that contains the changes to be merged",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :pull_request_base,
                                       env_name: "FL_SONAR_RUNNER_PULL_REQUEST_BASE",
                                       description: "The long-lived branch into which the PR will be merged",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :pull_request_key,
                                       env_name: "FL_SONAR_RUNNER_PULL_REQUEST_KEY",
                                       description: "Unique identifier of your PR. Must correspond to the key of the PR in GitHub or TFS",
                                       optional: true)
        ]
      end

      def self.return_value
        "The exit code of the sonar-scanner binary"
      end

      def self.authors
        ["c_gretzki"]
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
            sources_path: File.expand_path("../AwesomeApp")
          )',
          'sonar(
            project_key: "name.gretzki.awesomeApp",
            project_version: "1.0",
            project_name: "iOS - AwesomeApp",
            sources_path: File.expand_path("../AwesomeApp"),
            sonar_organization: "myOrg",
            sonar_token: "123456abcdef",
            sonar_url: "https://sonarcloud.io"
          )'
        ]
      end

      def self.category
        :testing
      end
    end
  end
end
