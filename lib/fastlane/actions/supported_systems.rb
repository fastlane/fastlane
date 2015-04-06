module Fastlane
  module Actions
    module SharedValues
      FASTLANE_OPERATING_SYSTEMS = :FASTLANE_OPERATING_SYSTEMS
    end

    class SupportedSystemsAction
      
      def self.is_supported?(type)
        true
      end

      def self.run(params)
        raise "Please pass valid parameters to supported_systems".red unless params.kind_of?Array
        Actions.lane_context[SharedValues::FASTLANE_OPERATING_SYSTEMS] = params
      end
    end
  end
end
