module Fastlane
  class FastlaneRequire
    class << self
      def install_gem_if_needed(gem_name: nil, require_gem: true)
        gem_require_name = gem_name.tr("-", "/") # from "fastlane-plugin-xcversion" to "fastlane/plugin/xcversion"
        bundle_path = "~/.fastlane/bin/"

        # check if it's installed
        if gem_installed?(gem_name)
          UI.success("gem '#{gem_name}' is already installed") if $verbose
          require gem_require_name if require_gem
          return true
        end

        require "rubygems/command_manager"
        installer = Gem::CommandManager.instance[:install]

        UI.important "Installing Ruby gem '#{gem_name}'..."
        return if Helper.test?

        # We install the gem like this because we also want to gem to be available to be required
        # at this point. If we were to shell out, this wouldn't be the case
        installer.install_gem(gem_name, Gem::Requirement.default)
        UI.success("Successfully installed '#{gem_name}' to '#{bundle_path}'")
        require gem_require_name if require_gem
      end

      def gem_installed?(name, req = Gem::Requirement.default)
        Gem::Specification.any? { |s| s.name == name and req =~ s.version }
      end
    end
  end
end
