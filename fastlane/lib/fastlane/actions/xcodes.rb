module Fastlane
  module Actions
    module SharedValues
      XCODE_INSTALL_XCODE_PATH = :XCODE_INSTALL_XCODE_PATH
    end

    class XcodesAction < Action
      def self.run(params)
        # Provide xcodes with the necessary env vars
        ENV["XCODES_USERNAME"] = params[:username]
        ENV["XCODES_PASSWORD"] = params[:password]
        binary = params[:binary_path]
        select_only = params[:select_only]
        if params[:update_list] && !select_only
          command = []
          command << binary
          command << "update"
          shell_command = command.join(' ')
          UI.message("Available versions:")
          Actions.sh(shell_command)
        end
        command = []
        command << binary
        if (xcodes_args = params[:xcodes_args])
          command << xcodes_args
        elsif select_only
          command << "select"
          command << "'#{params[:version]}'"
        else
          command << "install"
          command << "'#{params[:version]}'"
        end
        shell_command = command.join(' ')
        Actions.sh(shell_command)

        # Prints something like /Applications/Xcode-14.app/Contents/Developer/
        xcode_path = FastlaneCore::Helper.xcode_path
        UI.message("Using Xcode #{params[:version]} on path '#{xcode_path.chomp('/Contents/Developer/')}'")
        ENV["DEVELOPER_DIR"] = xcode_path
        Actions.lane_context[SharedValues::XCODE_INSTALL_XCODE_PATH] = xcode_path
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
          FastlaneCore::ConfigItem.new(key: :select_only,
                                       env_name: "FL_XCODES_SELECT_ONLY",
                                       description: "Whether the action should just select the version passed, instead of installing it if needed. When true, if the version isn't installed, an error will be raised",
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
          ['XCODE_INSTALL_XCODE_PATH', 'The path to the newly installed Xcode']
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
