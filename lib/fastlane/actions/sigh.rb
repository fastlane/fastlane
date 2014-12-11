module Fastlane
  module Actions
    def self.sigh(params)
      command = "sigh"
      command << " --adhoc" if params.first == :adhoc
      command << " --development" if params.first == :development
      sh command
    end
  end
end