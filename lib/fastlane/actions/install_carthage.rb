module Fastlane
  module Actions
    class CarthageAction < Action
      def self.run(params)

        cmd = ['carthage bootstrap']

        cmd << '--use-ssh' if params[:use_ssh]
        cmd << '--use-submodules' if params[:use_submodules]
        cmd << '--no-use-binaries' if !params[:use_binaries]
        cmd << '--platform' << params[:platform]

        Actions.sh(cmd.join(' '))
      end

      def self.description
        "Runs `carthage bootstrap` for your project"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :use_ssh,
                                       env_name: "FL_CARTHAGE_USE_SSH",
                                       description: "Use SSH for downloading GitHub repositories",
                                       default_value: false,
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :use_submodules,
                                       env_name: "FL_CARTHAGE_USE_SUBMODULES",
                                       description: "Add dependencies as Git submodules",
                                       default_value: false,
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :use_binaries,
                                       env_name: "FL_CARTHAGE_NO_USE_BINARIES",
                                       description: "Check out dependency repositories even when prebuilt frameworks exist",
                                       default_value: true,
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :platform,
                                       env_name: "FL_CARTHAGE_PLATFORM",
                                       description: "Define which platform to build for",
                                       default_value: "all",
                                       optional: true,
                                       verify_block: Proc.new do |value|
                                        raise "Please pass a valid platform. Use one of the following: all, iOS, Mac, watchOS" unless ['all', 'iOS', 'Mac', 'watchOS'].include?value
                                      end),
        ]
      end

      def self.is_supported?(platform)
        true
      end

      def self.authors
        ["bassrock", "petester42"]
      end
    end
  end
end
