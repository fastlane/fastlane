module Fastlane
  module Actions
    # This method will import a plugin
    def self.plugin(gem)
      Kernel.require "#{gem}"
    end
  end
end
