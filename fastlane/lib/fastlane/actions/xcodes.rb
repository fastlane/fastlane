module Fastlane
  module Actions
    module SharedValues
      XCODES_XCODE_PATH = :XCODES_XCODE_PATH
    end

    class XcodesAction < Action
      def self.run(params)
        binary = params[:binary_path]
        xcodes_raw_version = Actions.sh("#{binary} version", log: false)
        xcodes_version = Gem::Version.new(xcodes_raw_version)
        UI.message("Running xcodes version #{xcodes_version}")
        if xcodes_version < Gem::Version.new("1.1.0")
          UI.user_error!([
            "xcodes action requires the minimum version of xcodes binary to be v1.1.0.",
            "Please update xcodes. If you installed it via Homebrew, this can be done via 'brew upgrade xcodes'"
          ].join(" "))
        end

        version = params[:version]
        command = []
        command << binary

        if (xcodes_args = params[:xcodes_args])
          command << xcodes_args
          Actions.sh(command.join(" "))
        elsif !params[:select_for_current_build_only]
          command << "install"
          command << "'#{version}'"
          command << "--update" if params[:update_list]
          command << "--select"
          Actions.sh(command.join(" "))
        end

        command = []
        command << binary
        command << "installed"
        command << "'#{version}'"

        # `installed <version>` will either return the path to the given
        # version or fail because the version can't be found.
        #
        # Store the path if we get one, fail the action otherwise.
        xcode_path = Actions.sh(command.join(" ")) do |status, result, sh_command|
          formatted_result = result.chomp

          unless status.success?
            UI.user_error!("Command `#{sh_command}` failed with status #{status.exitstatus} and message: #{formatted_result}")
          end

          formatted_result
        end

        # If the command succeeded, `xcode_path` will be something like:
        # /Applications/Xcode-14.app
        xcode_developer_path = File.join(xcode_path, "/Contents/Developer")

        UI.message("Setting Xcode version '#{version}' at '#{xcode_path}' for all build steps")
        ENV["DEVELOPER_DIR"] = xcode_developer_path
        Actions.lane_context[SharedValues::XCODES_XCODE_PATH] = xcode_developer_path
        return xcode_path
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Make sure a certain version of Xcode is installed, installing it only if needed"
      end

      def self.details
        [
          "Makes sure a specific version of Xcode is installed. If that's not the case, it will automatically be downloaded by [xcodes](https://github.com/RobotsAndPencils/xcodes).",
          "This will make sure to use the correct Xcode version for later actions.",
          "Note that this action depends on [xcodes](https://github.com/RobotsAndPencils/xcodes) CLI, so make sure you have it installed in your environment. For the installation guide, see: https://github.com/RobotsAndPencils/xcodes#installation"
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "FL_XCODE_VERSION",
                                       description: "The version number of the version of Xcode to install. Defaults to the value specified in the .xcode-version file",
                                       default_value: Helper::XcodesHelper.read_xcode_version_file,
                                       default_value_dynamic: true,
                                       verify_block: Helper::XcodesHelper::Verify.method(:requirement)),
          FastlaneCore::ConfigItem.new(key: :update_list,
                                       env_name: "FL_XCODES_UPDATE_LIST",
                                       description: "Whether the list of available Xcode versions should be updated before running the install command",
                                       type: Boolean,
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :select_for_current_build_only,
                                       env_name: "FL_XCODES_SELECT_FOR_CURRENT_BUILD_ONLY",
                                       description: [
                                         "When true, it won't attempt to install an Xcode version, just find the installed Xcode version that best matches the passed version argument, and select it for the current build steps.",
                                         "It doesn't change the global Xcode version (e.g. via 'xcrun xcode-select'), which would require sudo permissions — when this option is true, this action doesn't require sudo permissions"
                                       ].join(" "),
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :binary_path,
                                       env_name: "FL_XCODES_BINARY_PATH",
                                       description: "Where the xcodes binary lives on your system (full path)",
                                       default_value: Helper::XcodesHelper.find_xcodes_binary_path,
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("'xcodes' doesn't seem to be installed. Please follow the installation guide at https://github.com/RobotsAndPencils/xcodes#installation before proceeding") if value.empty?
                                         UI.user_error!("Couldn't find xcodes binary at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :xcodes_args,
                                       env_name: "FL_XCODES_ARGS",
                                       description: "Pass in xcodes command line arguments directly. When present, other parameters are ignored and only this parameter is used to build the command to be executed",
                                       type: :shell_string,
                                       optional: true)
        ]
      end

      def self.output
        [
          ['XCODES_XCODE_PATH', 'The path to the newly installed Xcode version']
        ]
      end

      def self.return_value
        "The path to the newly installed Xcode version"
      end

      def self.return_type
        :string
      end

      def self.authors
        ["rogerluan"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'xcodes(version: "14.1")',
          'xcodes # When missing, the version value defaults to the value specified in the .xcode-version file'
        ]
      end

      def self.category
        :building
      end
    end
  end
end
