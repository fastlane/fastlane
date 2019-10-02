require 'rubygems/spec_fetcher'
require 'rubygems/command_manager'

module Fastlane
  module Actions
    # Makes sure fastlane tools are up-to-date when running fastlane
    class UpdateFastlaneAction < Action
      ALL_TOOLS = ["fastlane"]

      def self.run(options)
        return if options[:no_update] # this is used to update itself

        tools_to_update = ALL_TOOLS
        UI.message("Looking for updates for #{tools_to_update.join(', ')}...")

        updater = Gem::CommandManager.instance[:update]
        cleaner = Gem::CommandManager.instance[:cleanup]

        gem_dir = ENV['GEM_HOME'] || Gem.dir
        sudo_needed = !File.writable?(gem_dir)

        if sudo_needed
          UI.important("It seems that your Gem directory is not writable by your current user.")
          UI.important("fastlane would need sudo rights to update itself, however, running 'sudo fastlane' is not recommended.")
          UI.important("If you still want to use this action, please read the documentation on how to set this up:")
          UI.important("https://docs.fastlane.tools/actions/update_fastlane/")
          return
        end

        unless updater.respond_to?(:highest_installed_gems)
          UI.important("The update_fastlane action requires rubygems version 2.1.0 or greater.")
          UI.important("Please update your version of ruby gems before proceeding.")
          UI.command "gem install rubygems-update"
          UI.command "update_rubygems"
          UI.command "gem update --system"
          return
        end

        highest_versions = updater.highest_installed_gems.keep_if { |key| tools_to_update.include?(key) }
        update_needed = updater.which_to_update(highest_versions, tools_to_update)

        if update_needed.count == 0
          UI.success("Nothing to update ✅")
          return
        end

        # suppress updater output - very noisy
        Gem::DefaultUserInteraction.ui = Gem::SilentUI.new

        update_needed.each do |tool_info|
          tool = tool_info[0]
          local_version = Gem::Version.new(highest_versions[tool].version)
          latest_official_version = FastlaneCore::UpdateChecker.fetch_latest(tool)

          UI.message("Updating #{tool} from #{local_version.to_s.yellow} to #{latest_official_version.to_s.yellow}... 🚀")

          # Approximate_recommendation will create a string like "~> 0.10" from a version 0.10.0, e.g. one that is valid for versions >= 0.10 and <1.0
          requirement_version = local_version.approximate_recommendation
          updater.update_gem(tool, Gem::Requirement.new(requirement_version))

          UI.success("Finished updating #{tool}")
        end

        UI.message("Cleaning up old versions...")
        cleaner.options[:args] = tools_to_update
        cleaner.execute

        UI.message("fastlane.tools successfully updated! I will now restart myself... 😴")

        # Set no_update to true so we don't try to update again
        exec("FL_NO_UPDATE=true #{$PROGRAM_NAME} #{ARGV.join(' ')}")
      end

      def self.description
        "Makes sure fastlane-tools are up-to-date when running fastlane"
      end

      def self.details
        sample = <<-SAMPLE.markdown_sample
          ```bash
          export GEM_HOME=~/.gems
          export PATH=$PATH:~/.gems/bin
          ```
        SAMPLE

        [
          "This action will update fastlane to the most recent version - major version updates will not be performed automatically, as they might include breaking changes. If an update was performed, fastlane will be restarted before the run continues.",
          "",
          "If you are using rbenv or rvm, everything should be good to go. However, if you are using the system's default ruby, some additional setup is needed for this action to work correctly. In short, fastlane needs to be able to access your gem library without running in `sudo` mode.",
          "",
          "The simplest possible fix for this is putting the following lines into your `~/.bashrc` or `~/.zshrc` file:".markdown_preserve_newlines,
          sample,
          "After the above changes, restart your terminal, then run `mkdir $GEM_HOME` to create the new gem directory. After this, you're good to go!",
          "",
          "Recommended usage of the `update_fastlane` action is at the top inside of the `before_all` block, before running any other action."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :no_update,
                                       env_name: "FL_NO_UPDATE",
                                       description: "Don't update during this run. This is used internally",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :nightly,
                                       env_name: "FL_UPDATE_FASTLANE_NIGHTLY",
                                       description: "Opt-in to install and use nightly fastlane builds",
                                       is_string: false,
                                       default_value: false,
                                       deprecated: "Nightly builds are no longer being made available")
        ]
      end

      def self.authors
        ["milch", "KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end

      def self.example_code
        [
          'before_all do
            update_fastlane
            # ...
          end'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
