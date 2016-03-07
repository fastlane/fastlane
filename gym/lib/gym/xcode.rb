module Gym
  class Xcode
    class << self
      def xcode_path
        Helper.xcode_path
      end

      def xcode_version
        Helper.xcode_version
      end

      # Below Xcode 7 (which offers a new nice API to sign the app)
      def pre_7?
        v = xcode_version
        is_pre = v.split('.')[0].to_i < 7
        is_pre
      end
    end
  end
end
