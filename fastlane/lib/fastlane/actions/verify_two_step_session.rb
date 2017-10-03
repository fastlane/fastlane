module Fastlane
  module Actions
    class VerifyTwoStepSessionAction < Action
      def self.run(params)
        user = params[:user] || ENV["FASTLANE_USER"] || ENV["DELIVER_USER"] || ENV["DELIVER_USERNAME"]

        begin
          Spaceship::Tunes.login(user)
        rescue Spaceship::Client::InvalidUserCredentialsError => e
          # Invalid username and password combination
          UI.user_error!(e.message)
        rescue
          UI.user_error!('Your session cookie has been expired.')
        end

        UI.success('Login successful')

        cookie = nil
        if Spaceship::Tunes.client.load_session_from_file
          require 'yaml'
          cookie = YAML.safe_load(
            File.read(Spaceship::Tunes.client.persistent_cookie_path),
            [HTTP::Cookie, Time], # classes whitelist
            [],                   # symbols whitelist
            true                  # allow YAML aliases
          )
        end

        # If this is a CI, the user can pass the session via environment variable
        if Spaceship::Tunes.client.load_session_from_env
          cookie = Spaceship::Tunes.client.load_session_from_env
        end

        # user does not use 2 step verification
        return if cookie.nil?

        check_expiration_time(cookie)
      end

      def self.check_expiration_time(cookie)
        cookie.each do |content|
          next unless content.domain == 'idmsa.apple.com' && content.max_age.to_s.length > 0
          next unless content.created_at.to_s =~ /([0-9]{4})-([0-9]{2})-([0-9]{2}) ([0-9]{2}):([0-9]{2}):([0-9]{2})/
          year = Regexp.last_match(1).to_i
          month = Regexp.last_match(2).to_i
          day = Regexp.last_match(3).to_i
          hour = Regexp.last_match(4).to_i
          min = Regexp.last_match(5).to_i
          sec = Regexp.last_match(6).to_i

          created_date = DateTime.new(year, month, day, hour, min, sec)
          expiration_date = created_date + Rational(content.max_age, 24 * 60 * 60)
          remaining_days = (expiration_date - DateTime.now).to_i

          if remaining_days > 0
            UI.important("Your session cookie will expire at #{expiration_date.strftime('%Y-%m-%d %H:%M:%S')} (#{remaining_days} days left).")
          else
            UI.error("Your session cookie is due to expire today!")
          end
          break
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Verifies the session cookie for 'Two-Step verification for Apple ID'"
      end

      def self.details
        [
          "This action will validate the session cookie for 'Two-Step verification for Apple ID'"
          "and display the remaining days by expiration date."
        ].join(' ')
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :user,
                                       env_name: "FL_VERIFY_TWO_STEP_SESSION_USER",
                                       description: "User for Two-Step verification for Apple ID (email address)",
                                       optional: true)
        ]
      end

      def self.authors
        ["thasegaw"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'verify_two_step_session(user: test@example.com)'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
