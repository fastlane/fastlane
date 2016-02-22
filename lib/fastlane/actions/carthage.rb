module Fastlane
  module Actions
    class CarthageAction < Action
      def self.run(params)
        cmd = ['carthage']

        if params[:command]
          cmd << params[:command]
        else
          cmd << 'bootstrap'
        end

        cmd << "--platform #{params[:platform]}"           if params[:platform]
        cmd << '--verbose'                                 if params[:verbose]
        cmd << '--no-skip-current'                         if params[:no_skip_current]
        cmd << '--no-checkout'                             if params[:no_checkout]
        cmd << '--no-build'                                if params[:no_build]
        cmd << '--use-ssh'                                 if params[:use_ssh]
        cmd << '--use-submodules'                          if params[:use_submodules]
        cmd << '--no-use-binaries'                         if params[:no_use_binaries]

        Actions.sh(cmd.join(' '))
      end

      def self.description
        "Runs `carthage bootstrap` or `carthage update` for your project"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :command,
                                       env_name: "FL_CARTHAGE_COMMAND",
                                       description: "Carthage command (one of `build`, `bootstrap`, `update`)",
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Please pass a valid command. Use one of the following: build, bootstrap, update" unless %w(build bootstrap update).include? value
                                       end),
          FastlaneCore::ConfigItem.new(key: :platform,
                                       env_name: "FL_CARTHAGE_PLATFORM",
                                       description: "Define which platform to build for",
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Please pass a valid platform. Use one of the following: all, iOS, Mac, watchOS" unless ["all", "iOS", "Mac", "watchOS"].include? value
                                       end),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_CARTHAGE_VERBOSE",
                                       description: "Print xcodebuild output inline",
                                       is_string: false,
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Please pass a valid value for verbose. Use one of the following: true, false" unless value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
                                       end),
          FastlaneCore::ConfigItem.new(key: :no_skip_current,
                                       env_name: "FL_CARTHAGE_NO_SKIP_CURRENT",
                                       description: "Don't skip building the Carthage project (in addition to its dependencies)",
                                       is_string: false,
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Please pass a valid value for no_skip_current. Use one of the following: true, false" unless value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
                                       end),
          FastlaneCore::ConfigItem.new(key: :no_checkout,
                                       env_name: "FL_CARTHAGE_NO_CHECKOUT",
                                       description: "Skip the checking out of dependencies after updating",
                                       is_string: false,
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Please pass a valid value for no_checkout. Use one of the following: true, false" unless value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
                                       end),
          FastlaneCore::ConfigItem.new(key: :no_build,
                                       env_name: "FL_CARTHAGE_NO_BUILD",
                                       description: "When bootstrapping Carthage do not build",
                                       is_string: false,
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Please pass a valid value for no_build. Use one of the following: true, false" unless value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
                                       end),
          FastlaneCore::ConfigItem.new(key: :use_ssh,
                                       env_name: "FL_CARTHAGE_USE_SSH",
                                       description: "Use SSH for downloading GitHub repositories",
                                       is_string: false,
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Please pass a valid value for use_ssh. Use one of the following: true, false" unless value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
                                       end),
          FastlaneCore::ConfigItem.new(key: :use_submodules,
                                       env_name: "FL_CARTHAGE_USE_SUBMODULES",
                                       description: "Add dependencies as Git submodules",
                                       is_string: false,
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Please pass a valid value for use_submodules. Use one of the following: true, false" unless value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
                                       end),
          FastlaneCore::ConfigItem.new(key: :no_use_binaries,
                                       env_name: "FL_CARTHAGE_NO_USE_BINARIES",
                                       description: "Check out dependency repositories even when prebuilt frameworks exist",
                                       is_string: false,
                                       optional: true,
                                       verify_block: proc do |value|
                                         raise "Please pass a valid value for no_use_binaries. Use one of the following: true, false" unless value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
                                       end)
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end

      def self.authors
        ["bassrock", "petester42", "jschmid", "JaviSoto", "uny"]
      end
    end
  end
end
