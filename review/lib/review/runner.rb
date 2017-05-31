require 'spaceship'

module Review
  class Runner
    attr_accessor :spaceship

    # Uses the spaceship to download app metadata and then run all rule checkers
    def run
      FastlaneCore::PrintTable.print_values(config: Review.config,
                                         hide_keys: [:output_path],
                                             title: "Summary for review #{Fastlane::VERSION}")

      UI.message "Starting login with user '#{Review.config[:username]}'"
      Spaceship.login(Review.config[:username], nil)
      Spaceship.select_team
      UI.message "Successfully logged in"
      ensure_app_exists!
    end

    # Makes sure the current App ID exists. If not, it will show an appropriate error message
    def ensure_app_exists!
      return if Spaceship::App.find(Review.config[:app_identifier], mac: Review.config[:platform].to_s == 'macos')
    end
  end
end
