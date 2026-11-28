module Fastlane
  module Actions
    # will make sure a gem is installed. If it's not an appropriate error message is shown
    # this will *not* 'require' the gem
    def self.verify_gem!(gem_name)
      begin
        FastlaneRequire.install_gem_if_needed(gem_name: gem_name, require_gem: false)
        # We don't import this by default, as it's not always the same
        # also e.g. cocoapods is just required and not imported
      rescue Gem::LoadError
        UI.error("Could not find gem '#{gem_name}'")
        UI.error("")
        UI.error("If you installed fastlane using `gem install fastlane` run")
        UI.command("gem install #{gem_name}")
        UI.error("to install the missing gem")
        UI.error("")
        UI.error("If you use a Gemfile add this to your Gemfile:")
        UI.important("  gem '#{gem_name}'")
        UI.error("and run `bundle install`")

        UI.user_error!("You have to install the `#{gem_name}` gem on this machine") unless Helper.test?
      end
      true
    end
  end
end
