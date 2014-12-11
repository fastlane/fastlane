module Fastlane
  module Actions
    def self.install_cocoapods(params)
      sh("pod install")
    end
  end
end