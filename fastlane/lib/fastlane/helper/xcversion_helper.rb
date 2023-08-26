module Fastlane
  module Helper
    class XcversionHelper
      def self.find_xcode(req)
        req = Gem::Requirement.new(req.to_s)

        require 'xcode/install'
        installer = XcodeInstall::Installer.new
        installed = installer.installed_versions.reverse
        installed.detect do |xcode|
          req.satisfied_by?(Gem::Version.new(xcode.version))
        end
      end
    end
  end
end
