module Fastlane
  module Actions
    module SharedValues
      
    end

    class DeliverAction
      def self.run(params)
        require 'deliver'
        
        ENV["DELIVER_SCREENSHOTS_PATH"] = Actions.lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH]
        
        force = params.include?(:force)
        beta = params.include?(:beta)
        skip_deploy = params.include?(:skip_deploy)

        Deliver::Deliverer.new(nil, force: force, 
                              is_beta_ipa: beta, 
                              skip_deploy: skip_deploy)
      end
    end
  end
end