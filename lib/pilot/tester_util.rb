require "fastlane_core"

module Pilot
  # helper functions to format things in a common way
  # we might want to move this to fastlane core ?
  class TesterUtil
    def self.full_version(tester)
      latest_installed_date = tester.latest_install_date
      return nil unless latest_installed_date
      latest_installed_version = tester.latest_installed_version_number
      latest_installed_short_version = tester.latest_installed_build_number
      "#{latest_installed_version} (#{latest_installed_short_version})"
    end

    def self.pretty_install_date(tester)
      latest_installed_date = tester.latest_install_date
      return nil unless latest_installed_date
      Time.at((latest_installed_date / 1000)).strftime("%m/%d/%y %H:%M")
    end
  end
end
