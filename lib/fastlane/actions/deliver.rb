module Fastlane
  module Actions
    module SharedValues
      
    end

    def self.deliver(params)

      execute_action("deliver") do
        require 'deliver'
        
        ENV["DELIVER_SCREENSHOTS_PATH"] = self.lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH]
        
        force = params.include?(:force)
        beta = params.include?(:beta)
        skip_deploy = params.include?(:skip_deploy)

        Deliver::Deliverer.new(Deliver::Deliverfile::Deliverfile::FILE_NAME, force: force, 
                                                                       is_beta_ipa: beta, 
                                                                       skip_deploy: skip_deploy)
      end

    end
  end
end