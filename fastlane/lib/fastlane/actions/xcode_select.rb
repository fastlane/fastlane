module Fastlane
  module Actions
    # See: https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/xcode-select.1.html
    #
    # DESCRIPTION
    #   xcode-select controls the location of the developer directory used by xcrun(1), xcodebuild(1), cc(1),
    #   and other Xcode and BSD development tools. This also controls the locations that are searched for  by
    #   man(1) for developer tool manpages.
    #
    # DEVELOPER_DIR
    #   Overrides the active developer directory. When DEVELOPER_DIR  is  set,  its  value  will  be  used
    #   instead of the system-wide active developer directory.
    #
    #   Note that for historical reason, the developer directory is considered to be the Developer content
    #   directory inside the Xcode application (for  example  /Applications/Xcode.app/Contents/Developer).
    #   You  can  set  the  environment variable to either the actual Developer contents directory, or the
    #   Xcode application directory -- the xcode-select provided  shims  will  automatically  convert  the
    #   environment variable into the full Developer content path.
    #
    class XcodeSelectAction < Action

      def self.find_xcode(req)
        req = Gem::Requirement.new(req.to_s)

        Gem::Specification.find_by_name('xcode-install')
        require 'xcode/install'

        installer = XcodeInstall::Installer.new
        installed = installer.installed_versions.reverse
        installed.detect do |xcode|
          req.satisfied_by? Gem::Version.new(xcode.version)
        end
      rescue Gem::LoadError
        UI.error("The 'xcode-install' gem is needed to select Xcode by version number.")
        Actions.verify_gem!('xcode-install') # This is awkward and destined to fail but is used to get the install help messages
      end

      def self.run(params)
        xcode_path =
          case
          when params[:path]
            params[:path]
          when version = params[:version]
            xcode = find_xcode(version)
            UI.user_error!("Cannot find an installed Xcode satisfying '#{version}'") if xcode.nil?

            UI.verbose("Found Xcode version #{xcode.version} at #{xcode.path} satisfying requirement #{version}")
            xcode.path
          else
            UI.user_error!("path or version must be specified")
          end

        UI.message("Setting Xcode version to #{xcode_path} for all build steps")

        ENV["DEVELOPER_DIR"] = File.join(xcode_path, "/Contents/Developer")
      end

      def self.description
        "Select which Xcode to use, either by path or version"
      end

      def self.author
        "dtrenz"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "DEVELOPER_DIR",
                                       description: "The path of the Xcode to select",
                                       optional: true,
                                       conflicting_options: [:version],
                                       conflict_block: proc do |value|
                                         UI.user_error!("You cannot specify 'path' and '#{value.key}' options at the same time")
                                       end,
                                       verify_block: Verify.method(:path_exists)
                                      ),
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "FL_XCODE_VERSION",
                                       description: "The version of Xcode to select specified as a RubyGems style requirement string",
                                       optional: true,
                                       conflicting_options: [:path],
                                       conflict_block: proc do |value|
                                         UI.user_error!("You cannot specify 'version' and '#{value.key}' options at the same time")
                                       end,
                                       verify_block: Verify.method(:requirement)
                                      )
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end

      module Verify
        def self.requirement(req)
          Gem::Requirement.new(req.to_s)
        rescue Gem::Requirement::BadRequirementError
          UI.user_error!("The requirement '#{req}' is not a valid RubyGems style requirement")
        end

        def self.path_exists(path)
          UI.user_error!("Path '#{path}' does not exist") unless Dir.exist?(path)
        end
      end

    end
  end
end
