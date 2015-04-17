module Fastlane
  module Actions
    module SharedValues
      OPERATING_SYSTEMS = :OPERATING_SYSTEMS
    end

    class SupportedSystemsAction < Action
      
      def self.is_supported?(platform)
        true
      end

      def self.description
        "Define a list of operating systems this Fastfile supports"
      end

      def self.run(params)
        raise "Please pass valid parameters to supported_systems".red unless params.kind_of?Array
        Actions.lane_context[SharedValues::OPERATING_SYSTEMS] = params
      end
    end
  end
end
