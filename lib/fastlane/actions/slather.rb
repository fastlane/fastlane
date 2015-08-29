module Fastlane
  module Actions
    module SharedValues
      SLATHER_CUSTOM_VALUE = :SLATHER_CUSTOM_VALUE
    end

    class SlatherAction < Action
      def self.run(params)
        command = "slather coverage "

        if params[:input_format]
          command += " --input-format #{params[:input_format]}"
        end

        if params[:build_directory]
          command += " --build-directory #{params[:build_directory]}"
        end

        if params[:scheme]
          command += " --scheme #{params[:scheme]}"
        end

        if params[:buildkite]
          command += " --buildkite"
        end

        if params[:jenkins]
          command += " --jenkins"
        end

        if params[:travis]
          command += " --travis"
        end

        if params[:circleci]
          command += " --circleci"
        end

        if params[:coveralls]
          command += " --coveralls"
        end

        if params[:simple_output]
          command += " --simple-output"
        end

        if params[:gutter_json]
          command += " --gutter-json"
        end

        if params[:cobertura_xml]
          command += " --cobertura-xml"
        end

        if params[:html]
          command += " --html"
        end

        if params[:show]
          command += " --show"
        end

        if params[:source_directory]
          command += " --source-directory #{params[:source_directory]}"
        end

        if params[:output_directory]
          command += " --output-directory #{params[:output_directory]}"
        end

        if params[:ignore]
          command += " --ignore #{params[:ignore]}"
        end

        if params[:proj]
          command += " #{params[:proj]}"
        end

        sh command

        # sh "shellcommand ./path"

        # Actions.lane_context[SharedValues::SLATHER_CUSTOM_VALUE] = "my_val"
      end



      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Use slather to generate a code coverage report"
      end

      def self.details
        # Optional:
        # this is your change to provide a more detailed description of this action
        "Slather works with multiple code coverage formats including Xcode7 code coverage.\n" +
        "Slather is available at https://github.com/venmo/slather"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :build_directory,
                                       env_name: "FL_SLATHER_BUILD_DIRECTORY", # The name of the environment variable
                                       description: "The location of the build output", # a short description of this parameter
                                       verify_block: proc do |value|
                                          raise "No Build Directory specified, pass using `build_directory: 'location/of/your/build/output'`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :proj,
                                       env_name: "FL_SLATHER_PROJ", # The name of the environment variable
                                       description: "The project file that slather looks at", # a short description of this parameter
                                       verify_block: proc do |value|
                                         raise "No project file specified, pass using `proj: 'Project.xcodeproj'`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :scheme,
                                       env_name: "FL_SLATHER_SCHEME", # The name of the environment variable
                                       description: "Scheme to use when calling slather"
                                      ),
          FastlaneCore::ConfigItem.new(key: :input_format,
                                       env_name: "FL_SLATHER_INPUT_FORMAT", # The name of the environment variable
                                       description: "The input format that slather should look for"
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
                                       optional: true),
        ]
      end

      def self.output
        # Define the shared values you are going to provide
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["@mattdelves"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end
    end
  end
end
