require_relative 'module'

module Gym
  class Xcode
    class << self
      def xcode_path
        Helper.xcode_path
      end

      def xcode_version
        Helper.xcode_version
      end
    end
  end
end
