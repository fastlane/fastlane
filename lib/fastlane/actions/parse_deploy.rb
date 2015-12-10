module Fastlane
  module Actions
    module SharedValues
      PARSE_DEPLOY_EXIT_STATUS = :PARSE_DEPLOY_EXIT_STATUS
    end

    class ParseDeployAction < Action
      def self.run(params)
        parse_application = params[:application]
        parse_directory = params[:parse_directory]
        release_notes = params[:release_notes]

        if parse_application.to_s.length == 0
          deploy_info = "the default application"
        else
          deploy_info = "#{parse_application}"
        end
        Helper.log.info "Deploying Parse cloud files to #{deploy_info} ⛅️".green

        parse_path = File.expand_path(parse_directory)
        exit_code = 1
        if File.exist?(parse_path)
          Dir.chdir(parse_path) do
            raise "Please install `parse` using `curl -s https://www.parse.com/downloads/cloud_code/installer.sh | sudo /bin/bash`" unless !`which parse`.empty?
            command = "parse deploy"
            if parse_application && !parse_application.empty?
              command << " #{parse_application}"
            end
            if release_notes && !release_notes.empty?
              command << " --description=\"#{release_notes}\""
            end
            Helper.log.info "#{command}".yellow
            system(command)
            exit_code = $?.exitstatus
          end
        else
          raise "Skipping Parse deploy: Parse directory not found at path `#{parse_path}`".yellow
        end

        Actions.lane_context[SharedValues::PARSE_DEPLOY_EXIT_STATUS] = exit_code

        if exit_code != 0
          raise "Parse deploy failed with exit code #{exit_code}.".red
        end

        Helper.log.info "Finished deploying Parse to #{deploy_info} ☀️.".green

        return exit_code
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Deploy server-side code to Parse Cloud"
      end

      def self.details
        "Deploy server-side Parse `cloud` and `public` code to Parse Cloud. \nYou can specify the target application, release notes, and the path to your Parse directory."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :application,
                                       env_name: "FL_PARSE_DEPLOY_APPLICATION", # The name of the environment variable
                                       description: "Target Application for ParseDeployAction", # a short description of this parameter
                                       is_string: false, # true: verifies the input is a string, false: every kind of value
                                       optional: true,
                                       default_value: ""), # the default value if the user didn't provide one
          FastlaneCore::ConfigItem.new(key: :parse_directory,
                                       env_name: "FL_PARSE_DEPLOY_PARSE_DIRECTORY",
                                       description: "Directory in your project that holds your Parse code",
                                       is_string: true,
                                       optional: false,
                                       default_value: "./Parse/"),
          FastlaneCore::ConfigItem.new(key: :release_notes,
                                       env_name: "FL_PARSE_DEPLOY_RELEASE_NOTES",
                                       description: "Release notes for any changes",
                                       is_string: true,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['PARSE_DEPLOY_EXIT_STATUS', 'The exit status code from the `Parse deploy` command.']
        ]
      end

      def self.return_value
        "The exit status code from the `Parse deploy` command."
      end

      def self.authors
        ["teddynewell"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
