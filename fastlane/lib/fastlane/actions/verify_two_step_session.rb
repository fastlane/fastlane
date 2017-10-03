module Fastlane
  module Actions
    class VerifyTwoStepSessionAction < Action
      def self.run(params)
        user = params[:user] || ENV["FASTLANE_USER"] || ENV["DELIVER_USER"] || ENV["DELIVER_USERNAME"]

        begin
          Spaceship::Tunes.login(user)
        rescue Spaceship::Client::InvalidUserCredentialsError => e
          UI.user_error!(e.preferred_error_info)
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
        return unless cookie
        cookie.each do |content|
          next unless content.domain == 'idmsa.apple.com' && content.max_age.to_s.length > 0
          next unless content.created_at.to_s =~ /([0-9]{4})-([0-9]{2})-([0-9]{2}) ([0-9]{2}):([0-9]{2}):([0-9]{2})/
          year = Regexp.last_match(1)
          month = Regexp.last_match(2)
          day = Regexp.last_match(3)
          hour = Regexp.last_match(4)
          min = Regexp.last_match(5)
          sec = Regexp.last_match(6)

          created_date = DateTime.new(year.to_i, month.to_i, day.to_i, hour.to_i, min.to_i, sec.to_i)
          expire_date = created_date + Rational(content.max_age, 24 * 60 * 60)
          remain = (expire_date - DateTime.now).to_i

          if remain > 0
            UI.important("Your session cookie will expire at #{expire_date.strftime('%Y-%m-%d %H:%M:%S')} (#{remain} days left).")
          else
            UI.error("Your session cookie is due to expire today!") if remain == 0
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
        "Verifies the session cookie for 'Two-Step verification for Apple ID'"
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
