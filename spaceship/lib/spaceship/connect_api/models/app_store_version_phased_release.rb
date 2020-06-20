require_relative '../model'
module Spaceship
  class ConnectAPI
    class AppStoreVersionPhasedRelease
      include Spaceship::ConnectAPI::Model

      attr_accessor :phased_release_state
      attr_accessor :start_date
      attr_accessor :total_pause_duration
      attr_accessor :current_day_number

      module PhasedReleaseState
        INACTIVE = "INACTIVE"
      end

      attr_mapping({
        "phasedReleaseState" => "phased_release_state",
        "startDate" => "start_date",
        "totalPauseDuration" => "total_pause_duration",
        "currentDayNumber" => "current_day_number"
      })

      def self.type
        return "appStoreVersionPhasedReleases"
      end

      #
      # API
      #

      def delete!(filter: {}, includes: nil, limit: nil, sort: nil)
        Spaceship::ConnectAPI.delete_app_store_version_phased_release(app_store_version_phased_release_id: id)
      end
    end
  end
end
