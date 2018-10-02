require_relative 'base'

module Spaceship
  module TestFlight
    class Tester < Base
      # @return (String) The identifier of this tester, provided by App Store Connect
      # @example
      #   "60f858b4-60a8-428a-963a-f943a3d68d17"
      attr_accessor :tester_id

      # @return (String) The email of this tester
      # @example
      #   "tester@spaceship.com"
      attr_accessor :email

      # @return (String) The first name of this tester
      # @example
      #   "Cary"
      attr_accessor :first_name

      # @return (String) The last name of this tester
      # @example
      #   "Bennett"
      attr_accessor :last_name

      # @return (String)
      # @example
      #   "invited"
      #   "installed"
      #
      attr_accessor :status

      # @return (Integer) Date of the last modification of the status (e.g. invite sent)
      attr_accessor :status_mod_time

      # @return (Hash)
      # @example
      # {
      #  "latestInstalledAppAdamId": "1222374686",
      #  "latestInstalledBuildId": "20739770",
      #  "latestInstalledDate": "1496866405755",
      #  "latestInstalledShortVersion": "1.0",
      #  "latestInstalledVersion": "68"
      # }
      attr_accessor :latest_install_info

      attr_accessor :latest_installed_date

      # @return (Integer) Number of sessions
      attr_accessor :session_count

      attr_accessor :groups

      attr_mapping(
        'id' => :tester_id,
        'email' => :email,
        'status' => :status,
        'statusModTime' => :status_mod_time,
        'latestInstallInfo' => :latest_install_info,
        'sessionCount' => :session_count,
        'firstName' => :first_name,
        'lastName' => :last_name,
        'groups' => :groups
      )

      def latest_installed_date
        return nil unless latest_install_info
        latest_installed_date_value = latest_install_info["latestInstalledDate"]
        return nil unless latest_installed_date_value

        return latest_installed_date_value.to_i
      end

      def pretty_install_date
        return nil unless latest_installed_date

        Time.at((latest_installed_date / 1000)).strftime("%Y-%m-%d %H:%M")
      end

      # @return (Array) Returns all beta testers available for this account
      def self.all(app_id: nil)
        client.testers_for_app(app_id: app_id).map { |data| self.new(data) }
      end

      # *DEPRECATED: Use `Spaceship::TestFlight::Tester.search` method instead*
      def self.find(app_id: nil, email: nil)
        testers = self.search(app_id: app_id, text: email, is_email_exact_match: true)
        return testers.first
      end

      def status_mod_time
        Time.parse(super) if super.to_s.length > 0
      end

      # @return (Spaceship::TestFlight::Tester) Returns the testers matching the parameter.
      # ITC searchs all fields, and is full text. The search results are the union of all words in the search text
      # @param text (String) (required): Value used to filter the tester, case insensitive
      def self.search(app_id: nil, text: nil, is_email_exact_match: false)
        text = text.strip
        testers_matching_text = client.search_for_tester_in_app(app_id: app_id, text: text).map { |data| self.new(data) }
        testers_matching_text ||= []
        if is_email_exact_match
          text = text.downcase
          testers_matching_text = testers_matching_text.select do |tester|
            tester.email.downcase == text
          end
        end

        return testers_matching_text
      end

      def self.remove_testers_from_testflight(app_id: nil, tester_ids: nil)
        client.remove_testers_from_testflight(app_id: app_id, tester_ids: tester_ids)
      end

      def self.create_app_level_tester(app_id: nil, first_name: nil, last_name: nil, email: nil)
        client.create_app_level_tester(app_id: app_id,
                                       first_name: first_name,
                                       last_name: last_name,
                                       email: email)
      end

      def remove_from_app!(app_id: nil)
        client.delete_tester_from_app(app_id: app_id, tester_id: self.tester_id)
      end

      def remove_from_testflight!(app_id: nil)
        client.remove_testers_from_testflight(app_id: app_id, tester_ids: [self.tester_id])
      end

      def resend_invite(app_id: nil)
        client.resend_invite_to_external_tester(app_id: app_id, tester_id: self.tester_id)
      end
    end
  end
end
