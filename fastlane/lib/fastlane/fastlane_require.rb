module Fastlane
  class FastlaneRequire
    class << self
      def fastlane_require(gem_name)
        gem_require_name = gem_name.tr("-", "/") # from "fastlane-plugin-xcversion" to "fastlane/plugin/xcversion"
        bundle_path = "~/.fastlane/bin/"

        # check if it's installed
        if gem_installed?(gem_name)
          UI.success("gem '#{gem_name}' is already installed")
          require gem_require_name
          return true
        end

        require "rubygems/command_manager"
        installer = Gem::CommandManager.instance[:install]

        UI.message "Installing '#{gem_name}'..."
        # We install the gem like this because we also want to gem to be available to be required
        # at this point. If we were to shell out, this wouldn't be the case
        installer.install_gem(gem_name, Gem::Requirement.default)
        UI.success("Successfully installed '#{gem_name}' to '#{bundle_path}'")
        require gem_require_name
      end

      def gem_installed?(name, req = Gem::Requirement.default)
        Gem::Specification.any? { |s| s.name == name and req =~ s.version }
      end
    end
  end
end
