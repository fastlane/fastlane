module Fastlane
  module Actions
    module SharedValues
    end

    class TeamNameAction < Action
      def self.run(params)
        params = nil unless params.kind_of? Array
        team = (params || []).first
        raise "Please pass your Team Name (e.g. team_name 'Felix Krause')".red unless team.to_s.length > 0

        Helper.log.info "Setting Team Name to '#{team}' for all build steps"

        [:FASTLANE_TEAM_NAME, :PRODUCE_TEAM_NAME].each do |current|
          ENV[current.to_s] = team
        end
      end

      def self.description
        "Set a team to use by its name"
      end

      def self.author
        "KrauseFx"
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
