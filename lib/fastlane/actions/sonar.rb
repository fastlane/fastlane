module Fastlane
  module Actions
    class SonarAction < Action
      def self.run(params)
        verify_sonar_runner_binary

        command_prefix = [
          'cd',
          File.expand_path('.').shellescape,
          '&&'
        ].join(' ')

        sonar_runner_args = []
        sonar_runner_args << "-Dproject.settings=\"#{params[:project_configuration_path]}\"" if params[:project_configuration_path]
        sonar_runner_args << "-Dsonar.projectKey=\"#{params[:project_key]}\"" if params[:project_key]
        sonar_runner_args << "-Dsonar.projectName=\"#{params[:project_name]}\"" if params[:project_name]
        sonar_runner_args << "-Dsonar.projectVersion=\"#{params[:project_version]}\"" if params[:project_version]
        sonar_runner_args << "-Dsonar.sources=\"#{params[:sources_path]}\"" if params[:sources_path]

        command = [
          command_prefix,
          'sonar-runner',
          sonar_runner_args
        ].join(' ')

        Action.sh command
      end

      def self.verify_sonar_runner_binary
        raise "You have to install sonar-runner using `brew install sonar-runner`".red unless `which sonar-runner`.to_s.length > 0 or !Helper.test?
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Invokes sonar-runner to programmatically run SonarQube analysis"
      end

      def self.details
        "See http://docs.sonarqube.org/display/SONAR/Analyzing+with+SonarQube+Scanner for details."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :project_configuration_path,
                                        env_name: "FL_SONAR_RUNNER_PROPERTIES_PATH",
                                        description: "The path to your sonar project configuration file; defaults to `sonar-project.properties`", # default is enforced by sonar-runner binary
                                        optional: true,
                                        verify_block: proc do |value|
                                          raise "Couldn't find file at path '#{value}'".red unless value.nil? or File.exist?(value)
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
                                       optional: true)
        ]
      end

      def self.return_value
        "The exit code of the sonar-runner binary"
      end

      def self.authors
        ["c_gretzki"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
