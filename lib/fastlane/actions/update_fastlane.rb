require 'rubygems/spec_fetcher'
require 'rubygems/commands/update_command'
require "open3"

module Fastlane
  module Actions
    # Makes sure fastlane tools are up-to-date when running fastlane 
    class UpdateFastlaneAction < Action

      ALL_TOOLS = [
        "fastlane",
        "fastlane_core",
        "deliver",
        "snapshot",
        "frameit",
        "pem",
        "sigh",
        "produce",
        "cert",
        "codes"
      ]

      def self.run(params)
        options = ConfigurationHelper.parse(self, params)

        tools_to_update = options[:tools]
        tools_to_update ||= all_installed_tools

        updater = Gem::Commands::UpdateCommand.new

        puts Fastlane::VERSION

        sudo_needed = !File.writable?(Gem.dir)

        if sudo_needed
          # TODO: Think up how to do this properly
          #Helper.log.info "Fastlane needs your password to update the fastlane-tools."
          #Action.sh "sudo gem update " + tools_to_update.join(" ")
        else
          highest_versions = updater.highest_installed_gems

          #suppress updater output - very noisy
          Gem::DefaultUserInteraction.ui = Gem::SilentUI.new

          tools_to_update.each do |tool| 
            updater.update_gem tool
          end

          any_updates = updater.updated.any? do |updated_tool|
            updated_tool.version > highest_versions[updated_tool.name].version
          end

          if any_updates
            Helper.log.info "fastlane.tools succesfully updated! I will now restart myself... 😴"
            exec "fastlane #{ARGV.join ' '}"
          else 
            Helper.log.info "All fastlane tools are up-to-date!"
          end
        end
      end

      def self.all_installed_tools
        Gem::Specification.select { |s| ALL_TOOLS.include? s.name }.map {|s| s.name}.uniq
      end

      def self.description
        "Makes sure fastlane-tools are up-to-date when running fastlane"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :tools,
                                       env_name: "FL_TOOLS_TO_UPDATE",
                                       description: "An array of the fastlane-tools to update. If not specified, all installed fastlane-tools will be updated",
                                       optional: true),
        ]
      end

      def self.author
        "milch"
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
