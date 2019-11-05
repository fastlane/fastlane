module Fastlane
  module Actions
    module SharedValues
      XCODE_INSTALL_XCODE_PATH = :XCODE_INSTALL_XCODE_PATH
    end

    class XcodeInstallAction < Action
      def self.run(params)
        Actions.verify_gem!('xcode-install')

        ENV["XCODE_INSTALL_USER"] = params[:username]
        ENV["XCODE_INSTALL_TEAM_ID"] = params[:team_id]

        require 'xcode/install'
        installer = XcodeInstall::Installer.new

        if installer.installed?(params[:version])
          UI.success("Xcode #{params[:version]} is already installed ✨")
        else
          installer.install_version(params[:version], true, true, true, true)
        end

        xcode = installer.installed_versions.find { |x| x.version == params[:version] }
        UI.user_error!("Could not find Xcode with version '#{params[:version]}'") unless xcode
        UI.message("Using Xcode #{params[:version]} on path '#{xcode.path}'")
        xcode.approve_license

        ENV["DEVELOPER_DIR"] = File.join(xcode.path, "/Contents/Developer")
        Actions.lane_context[SharedValues::XCODE_INSTALL_XCODE_PATH] = xcode.path
        return xcode.path
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Make sure a certain version of Xcode is installed"
      end

      def self.details
        "Makes sure a specific version of Xcode is installed. If that's not the case, it will automatically be downloaded by the [xcode_install](https://github.com/neonichu/xcode-install) gem. This will make sure to use the correct Xcode for later actions."
      end

      def self.available_options
        user = CredentialsManager::AppfileConfig.try_fetch_value(:apple_dev_portal_id)
        user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

        [
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "FL_XCODE_VERSION",
                                       description: "The version number of the version of Xcode to install",
                                       verify_block: proc do |value|
                                       end),
          FastlaneCore::ConfigItem.new(key: :username,
                                       short_option: "-u",
                                       env_name: "XCODE_INSTALL_USER",
                                       description: "Your Apple ID Username",
                                       default_value: user,
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                       short_option: "-b",
                                       env_name: "XCODE_INSTALL_TEAM_ID",
                                       description: "The ID of your team if you're in multiple teams",
                                       optional: true,
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                       default_value_dynamic: true)
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
        ["Krausefx"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'xcode_install(version: "7.1")'
        ]
      end

      def self.category
        :building
      end
    end
  end
end
