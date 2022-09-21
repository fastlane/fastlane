module Fastlane
  module Actions
    module SharedValues
      XCODES_XCODE_PATH = :XCODES_XCODE_PATH
    end

    class XcodesAction < Action
      def self.run(params)
        # Provide xcodes with the necessary env vars
        ENV["XCODES_USERNAME"] = params[:username]
        ENV["XCODES_PASSWORD"] = params[:password]
        binary = params[:binary_path]
        select_for_current_build_only = params[:select_for_current_build_only]
        version = params[:version]
        if params[:update_list] && !select_for_current_build_only
          command = []
          command << binary
          command << "update"
          shell_command = command.join(' ')
          UI.message("Available versions:")
          Actions.sh(shell_command)
        end

        if (xcodes_args = params[:xcodes_args])
          command = []
          command << binary
          command << xcodes_args
          shell_command = command.join(' ')
          Actions.sh(shell_command)
        elsif !select_for_current_build_only
          command = []
          command << binary
          command << "install"
          command << "'#{version}'"
          shell_command = command.join(' ')
          Actions.sh(shell_command)
        end

        command = []
        command << binary
        command << "installed"
        command << "'#{version}'"
        shell_command = command.join(' ')
        # Prints something like /Applications/Xcode-14.app
        xcode_path = Actions.sh(shell_command).strip
        xcode_developer_path = xcode_path + "/Contents/Developer/"

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
        "Makes sure a specific version of Xcode is installed. If that's not the case, it will automatically be downloaded by [xcodes](https://github.com/RobotsAndPencils/xcodes). This will make sure to use the correct Xcode version for later actions."
      end

      def self.available_options
        user = CredentialsManager::AppfileConfig.try_fetch_value(:apple_dev_portal_id)
        user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

        [
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "FL_XCODE_VERSION",
                                       description: "The version number of the version of Xcode to install. Defaults to the value specified in the .xcode-version file",
                                       default_value: Helper::XcodesHelper.read_xcode_version_file,
                                       default_value_dynamic: true,
                                       verify_block: Helper::XcodesHelper::Verify.method(:requirement)),
          FastlaneCore::ConfigItem.new(key: :username,
                                       short_option: "-u",
                                       env_names: ["FL_XCODES_USERNAME", "XCODES_USERNAME"],
                                       description: "Your Apple ID username",
                                       default_value: user,
                                       default_value_dynamic: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :password,
                                       short_option: "-p",
                                       env_names: ["FASTLANE_PASSWORD", "XCODES_PASSWORD"],
                                       description: "Your Apple ID password",
                                       code_gen_sensitive: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :update_list,
                                       env_name: "FL_XCODES_UPDATE_LIST",
                                       description: "Whether the list of available Xcode versions should be updated before running the install command",
                                       type: Boolean,
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :select_for_current_build_only,
                                       env_name: "FL_XCODES_SELECT_FOR_CURRENT_BUILD_ONLY",
                                       description: "When true, it won't attempt to install an Xcode version, just find the installed Xcode version that best matches the passed version argument, and select it for the current build steps. It doesn't change the global Xcode version (e.g. via 'xcrun xcode-select'), which would require sudo permissions — when this option is true, this action doesn't require sudo permissions",
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :binary_path,
                                       env_name: "FL_XCODES_BINARY_PATH",
                                       description: "Where the xcodes binary lives on your system (full path)",
                                       default_value: Helper::XcodesHelper.find_xcodes_binary_path,
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
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
          ['XCODES_XCODE_PATH', 'The path to the newly installed Xcode']
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
