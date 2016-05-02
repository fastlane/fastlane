module Fastlane
  module Helper
    class XcodeSelectHelper
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
