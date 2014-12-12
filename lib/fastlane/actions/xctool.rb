module Fastlane
  module Actions
    def self.xctool(params)
      sh("xctool " + params.join(" "))
    end
  end
end