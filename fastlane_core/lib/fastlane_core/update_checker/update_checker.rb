require 'excon'
require 'digest'

require_relative 'changelog'
require_relative '../analytics/app_identifier_guesser'
require_relative '../helper'
require_relative '../ui/ui'

module FastlaneCore
  # Verifies, the user runs the latest version of this gem
  class UpdateChecker
    def self.start_looking_for_update(gem_name)
      return if Helper.test?
      return if FastlaneCore::Env.truthy?("FASTLANE_SKIP_UPDATE_CHECK")

      @start_time = Time.now

      Thread.new do
        begin
          server_results[gem_name] = fetch_latest(gem_name)
        rescue
          # we don't want to show a stack trace if something goes wrong
        end
      end
    end

    def self.server_results
      @results ||= {}
    end

    class << self
      attr_reader :start_time
    end

    def self.update_available?(gem_name, current_version)
      latest = server_results[gem_name]
      return (latest and Gem::Version.new(latest) > Gem::Version.new(current_version))
    end

    def self.show_update_status(gem_name, current_version)
      if update_available?(gem_name, current_version)
        show_update_message(gem_name, current_version)
      end
    end

    # Show a message to the user to update to a new version of fastlane (or a sub-gem)
    # Use this method, as this will detect the current Ruby environment and show an
    # appropriate message to the user
    def self.show_update_message(gem_name, current_version)
      available = server_results[gem_name]
      puts("")
      puts('#######################################################################')
      if available
        puts("# #{gem_name} #{available} is available. You are on #{current_version}.")
      else
        puts("# An update for #{gem_name} is available. You are on #{current_version}.")
      end
      puts("# You should use the latest version.")
      puts("# Please update using `#{self.update_command(gem_name: gem_name)}`.")

      puts("# To see what's new, open https://github.com/fastlane/#{gem_name}/releases.") if FastlaneCore::Env.truthy?("FASTLANE_HIDE_CHANGELOG")

      if !Helper.bundler? && !Helper.contained_fastlane? && Random.rand(5) == 1
        # We want to show this message from time to time, if the user doesn't use bundler, nor bundled fastlane
        puts('#######################################################################')
        puts("# Run `gem cleanup` from time to time to speed up fastlane")
      end
      puts('#######################################################################')
      Changelog.show_changes(gem_name, current_version, update_gem_command: UpdateChecker.update_command(gem_name: gem_name)) unless FastlaneCore::Env.truthy?("FASTLANE_HIDE_CHANGELOG")

      ensure_rubygems_source
    end

    # The command that the user should use to update their mac
    def self.update_command(gem_name: "fastlane")
      if Helper.bundler?
        "bundle update #{gem_name.downcase}"
      elsif Helper.contained_fastlane? || Helper.homebrew?
        "fastlane update_fastlane"
      elsif Helper.mac_app?
        "the Fabric app. Launch the app and navigate to the fastlane tab to get the most recent version."
      else
        "gem install #{gem_name.downcase}"
      end
    end

    # Check if RubyGems is set as a gem source
    # on some machines that might not be the case
    # and then users can't find the update when
    # running the specified command
    def self.ensure_rubygems_source
      return if Helper.contained_fastlane?
      return if `gem sources`.include?("https://rubygems.org")
      puts("")
      UI.error("RubyGems is not listed as your Gem source")
      UI.error("You can run `gem sources` to see all your sources")
      UI.error("Please run the following command to fix this:")
      UI.command("gem sources --add https://rubygems.org")
    end

    def self.fetch_latest(gem_name)
      JSON.parse(Excon.get(generate_fetch_url(gem_name)).body)["version"]
    end

    def self.generate_fetch_url(gem_name)
      "https://rubygems.org/api/v1/gems/#{gem_name}.json"
    end
  end
end
