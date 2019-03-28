module Fastlane
  class FastlaneRequire
    class << self
      def install_gem_if_needed(gem_name: nil, require_gem: true)
        gem_require_name = format_gem_require_name(gem_name)

        # check if it's installed
        if gem_installed?(gem_name)
          if FastlaneCore::Globals.verbose?
            UI.success("gem '#{gem_name}' is already installed")
          end
          require gem_require_name if require_gem
          return true
        end

        if Helper.bundler?
          # User uses bundler, we don't want to install gems on the fly here
          # Instead tell the user how to add it to their Gemfile
          UI.important(
            "Missing gem '#{gem_name}', please add the following to your local Gemfile:"
          )
          UI.important('')
          UI.command_output("gem \"#{gem_name}\"")
          UI.important('')
          unless Helper.test?
            UI.user_error!(
              "Add 'gem \"#{gem_name}\"' to your Gemfile and restart fastlane"
            )
          end
        end

        require 'rubygems/command_manager'
        installer = Gem::CommandManager.instance[:install]

        UI.important("Installing Ruby gem '#{gem_name}'...")

        spec_name = self.find_gem_name(gem_name)
        if spec_name != gem_name
          UI.important(
            "Found gem \"#{spec_name}\" instead of the required name \"#{gem_name}\""
          )
        end

        return if Helper.test?

        # We install the gem like this because we also want to gem to be available to be required
        # at this point. If we were to shell out, this wouldn't be the case
        installer.install_gem(spec_name, Gem::Requirement.default)
        UI.success("Successfully installed '#{gem_name}'")
        require gem_require_name if require_gem
      end

      def gem_installed?(name, req = Gem::Requirement.default)
        installed =
          Gem::Specification.any? { |s| s.name == name and req =~ s.version }
        return true if installed

        # In special cases a gem is already preinstalled, e.g. YAML.
        # To find out we try to load a gem with that name in a child process
        # (so we don't actually load anything we don't want to load)
        # See https://github.com/fastlane/fastlane/issues/6951
        require_tester =
          <<-RB
          begin
            require ARGV.first
          rescue LoadError
            exit(1)
          end
        RB
            .gsub(/^ */, '')
        system(
          RbConfig.ruby,
          '-e',
          require_tester.lines.map(&:chomp).join('; '),
          name
        )
        return $?.success?
      end

      def find_gem_name(user_supplied_name)
        fetcher = Gem::SpecFetcher.fetcher
        gems = fetcher.suggest_gems_from_name(user_supplied_name)

        return gems.first
      end

      def format_gem_require_name(gem_name)
        # from "fastlane-plugin-xcversion" to "fastlane/plugin/xcversion"
        if gem_name.start_with?('fastlane-plugin-')
          gem_name = gem_name.tr('-', '/')
        end

        return gem_name
      end
    end
  end
end
