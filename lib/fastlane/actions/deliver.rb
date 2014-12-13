module Fastlane
  module Actions
    def self.deliver(params)

      execute_action("deliver") do
        need_gem!'deliver'

        require 'deliver'
        ENV["DELIVER_SCREENSHOTS_PATH"] = self.snapshot_screenshots_folder
        
        force = false
        force = true if params.first == :force

        Deliver::Deliverer.new(Deliver::Deliverfile::Deliverfile::FILE_NAME, force: force)
      end

    end
  end
end