module Fastlane
  class FastlaneRequire
    class << self
      def install_gem_if_needed(gem_name: nil, require_gem: true)
        gem_require_name = gem_name.tr("-", "/") # from "fastlane-plugin-xcversion" to "fastlane/plugin/xcversion"

        # check if it's installed
        if gem_installed?(gem_name)
          UI.success("gem '#{gem_name}' is already installed") if $verbose
          require gem_require_name if require_gem
          return true
        end

        if Helper.bundler?
          # User uses bundler, we don't want to install gems on the fly here
          # Instead tell the user how to add it to their Gemfile
          UI.important("Missing gem '#{gem_name}', please add the following to your local Gemfile:")
          UI.important("")
          UI.command_output("gem \"#{gem_name}\"")
          UI.important("")
          UI.user_error!("Add 'gem \"#{gem_name}\"' to your Gemfile and restart fastlane") unless Helper.test?
        end

        require "rubygems/command_manager"
        installer = Gem::CommandManager.instance[:install]

        UI.important "Installing Ruby gem '#{gem_name}'..."

        spec_name = self.find_gem_name(gem_name)
        UI.important("Found gem \"#{spec_name}\" instead of the required name \"#{gem_name}\"") if spec_name != gem_name

        return if Helper.test?

        # We install the gem like this because we also want to gem to be available to be required
        # at this point. If we were to shell out, this wouldn't be the case
        installer.install_gem(spec_name, Gem::Requirement.default)
        UI.success("Successfully installed '#{gem_name}'")
        require gem_require_name if require_gem
      end

      def gem_installed?(name, req = Gem::Requirement.default)
        # We fork and try to load a gem with that name in the child process so we
        # don't actually load anything we don't want to load
        # This is just to test if the gem is already preinstalled, e.g. YAML
        # See https://github.com/fastlane/fastlane/issues/6951
        fork do
          begin
            exit(1) unless require name
          rescue LoadError
            exit(1)
          end
        end
        _, status = Process.wait2
        return true if status.exitstatus == 0

        Gem::Specification.any? { |s| s.name == name and req =~ s.version }
      end

      def find_gem_name(user_supplied_name)
        fetcher = Gem::SpecFetcher.fetcher
        gems = fetcher.suggest_gems_from_name(user_supplied_name)

        return gems.first
      end
    end
  end
end
