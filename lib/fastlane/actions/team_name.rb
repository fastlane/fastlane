module Fastlane
  module Actions
    module SharedValues
    end

    class TeamNameAction
      
      def self.is_supported?(type)
        type == :ios
      end

      def self.run(params)
        team = params.first
        raise "Please pass your Team Name (e.g. team_name 'Felix Krause')".red unless team.to_s.length > 0

        Helper.log.info "Setting Team Name to '#{team}' for all build steps"

        [:FASTLANE_TEAM_NAME, :PRODUCE_TEAM_NAME].each do |current|
          ENV[current.to_s] = team
        end
      end
    end
  end
end
