module Fastlane
  module Helper
    class XcversionHelper
      def self.find_xcode(req)
        req = Gem::Requirement.new(req.to_s)

        begin
          require 'xcode/install'
        rescue
          UI.user_error!("Please make sure that xcode-install/xcversion is installed before running this action.")
        end

        installer = XcodeInstall::Installer.new
        installed = installer.installed_versions.reverse
        installed.detect do |xcode|
          req.satisfied_by? Gem::Version.new(xcode.version)
        end
      end

      module Verify
        def self.requirement(req)
          UI.user_error!("Version must be specified") if req.nil? || req.to_s.strip.size == 0
          Gem::Requirement.new(req.to_s)
        rescue Gem::Requirement::BadRequirementError
          UI.user_error!("The requirement '#{req}' is not a valid RubyGems style requirement")
        end
      end
    end
  end
end
