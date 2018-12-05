require_relative 'app_version_states_history'

module Spaceship
  module Tunes
    # Represents a read only version of an App Store Connect Versions State History
    class AppVersionHistory < TunesBase
      # @return (Spaceship::Tunes::Application) A reference to the application
      #   this version is for
      attr_accessor :application

      # @return (String) The version in string format (e.g. "1.0")
      attr_reader :version_string

      # @return (String) The platform value of this version.
      attr_reader :version_id

      # @return ([Spaceship::Tunes::AppVersionStatesHistory]) the array of version states
      attr_reader :items

      attr_mapping({
        'versionString' => :version_string,
        'versionId' => :version_id,
        'items' => :items
      })

      # Returns an array of all builds that can be sent to review
      def items
        @items ||= fetch_items
      end

      # Private methods
      def setup
        # Properly parse the AppStatus
        items = raw_data['items']
        @items = map_items(items) if items
      end

      private

      def map_items(items)
        items.map do |attrs|
          Tunes::AppVersionStatesHistory.factory(attrs)
        end
      end

      def fetch_items
        items = client.version_states_history(application.apple_id, application.platform, version_id)['items']
        map_items(items)
      end
    end
  end
end
