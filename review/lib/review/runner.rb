require 'spaceship'
require 'review/rule_processor'

module Review
  class Runner
    attr_accessor :spaceship

    # Uses the spaceship to download app metadata and then run all rule checkers
    def run
      FastlaneCore::PrintTable.print_values(config: Review.config,
                                         hide_keys: [:output_path],
                                             title: "Summary for review #{Fastlane::VERSION}")

      UI.message "Starting login with user '#{Review.config[:username]}'"
      Spaceship::Tunes.login(Review.config[:username])
      Spaceship::Tunes.select_team
      UI.message "Successfully logged in"

      ensure_app_exists!

      check_for_rule_violations(app_version: latest_app_version)
    end

    def check_for_rule_violations(app_version: nil)
      Review::RuleProcessor.process_app_version(app_version: app_version)
    end

    def app
      Spaceship::Tunes::Application.find(Review.config[:app_identifier])
    end

    def latest_app_version
      app.latest_version
    end

    # Makes sure the current App ID exists. If not, it will show an appropriate error message
    def ensure_app_exists!
      return if app
      UI.user_error!("Could not find App with App Identifier '#{Review.config[:app_identifier]}'")
    end
  end
end
