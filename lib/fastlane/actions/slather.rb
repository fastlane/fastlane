module Fastlane
  module Actions
    module SharedValues
      SLATHER_CUSTOM_VALUE = :SLATHER_CUSTOM_VALUE
    end

    class SlatherAction < Action
      def self.run(params)
        Actions.verify_gem!('slather')

        command = "slather coverage "
        command += " --build-directory #{params[:build_directory]}" if params[:build_directory]
        command += " --input-format #{params[:input_format]}" if params[:input_format]
        command += " --scheme #{params[:scheme]}" if params[:scheme]
        command += " --buildkite" if params[:buildkite]
        command += " --jenkins" if params[:jenkins]
        command += " --travis" if params[:travis]
        command += " --circleci" if params[:circleci]
        command += " --coveralls" if params[:coveralls]
        command += " --simple-output" if params[:simple_output]
        command += " --gutter-json" if params[:gutter_json]
        command += " --cobertura-xml" if params[:cobertura_xml]
        command += " --html" if params[:html]
        command += " --show" if params[:show]
        command += " --source-directory #{params[:source_directory]}" if params[:source_directory]
        command += " --output-directory #{params[:output_directory]}" if params[:output_directory]
        command += " --ignore #{params[:ignore]}" if params[:ignore]
        command += " #{params[:proj]}"
        sh command
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Use slather to generate a code coverage report"
      end

      def self.details
        return <<-eos
Slather works with multiple code coverage formats including Xcode7 code coverage.
Slather is available at https://github.com/venmo/slather
        eos
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :build_directory,
                                       env_name: "FL_SLATHER_BUILD_DIRECTORY", # The name of the environment variable
                                       description: "The location of the build output", # a short description of this parameter
                                       optional: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :proj,
                                       env_name: "FL_SLATHER_PROJ", # The name of the environment variable
                                       description: "The project file that slather looks at", # a short description of this parameter
                                       verify_block: proc do |value|
                                         raise "No project file specified, pass using `proj: 'Project.xcodeproj'`".red unless value and !value.empty?
                                       end),
          FastlaneCore::ConfigItem.new(key: :scheme,
                                       env_name: "FL_SLATHER_SCHEME", # The name of the environment variable
                                       description: "Scheme to use when calling slather",
                                       optional: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :input_format,
                                       env_name: "FL_SLATHER_INPUT_FORMAT", # The name of the environment variable
                                       description: "The input format that slather should look for",
                                       optional: true
                                      ),
          FastlaneCore::ConfigItem.new(key: :buildkite,
                                       env_name: "FL_SLATHER_BUILDKITE_ENABLED", # The name of the environment variable
                                       description: "Tell slather that it is running on Buildkite",
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :jenkins,
                                       env_name: "FL_SLATHER_JENKINS_ENABLED", # The name of the environment variable
                                       description: "Tell slather that it is running on Jenkins",
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :travis,
                                       env_name: "FL_SLATHER_TRAVIS_ENABLED", # The name of the environment variable
                                       description: "Tell slather that it is running on TravisCI",
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :circleci,
                                       env_name: "FL_SLATHER_CIRCLECI_ENABLED",
                                       description: "Tell slather that it is running on CircleCI",
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :coveralls,
                                       env_name: "FL_SLATHER_COVERALLS_ENABLED",
                                       description: "Tell slather that it should post data to Coveralls",
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :simple_output,
                                       env_name: "FL_SLATHER_SIMPLE_OUTPUT_ENABLED",
                                       description: "Tell slather that it should output results to the terminal",
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :gutter_json,
                                       env_name: "FL_SLATHER_GUTTER_JSON_ENABLED",
                                       description: "Tell slather that it should output results as Gutter JSON format",
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :cobertura_xml,
                                       env_name: "FL_SLATHER_COBERTURA_XML_ENABLED",
                                       description: "Tell slather that it should output results as Cobertura XML format",
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :html,
                                       env_name: "FL_SLATHER_HTML_ENABLED",
                                       description: "Tell slather that it should output results as static HTML pages",
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :show,
                                       env_name: "FL_SLATHER_SHOW_ENABLED",
                                       description: "Tell slather that it should oupen static html pages automatically",
                                       is_string: false,
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
                                       description: "Tell slather to ignore files matching a path",
                                       optional: true)
        ]
      end

      def self.output
        # Define the shared values you are going to provide
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["mattdelves"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end
    end
  end
end
