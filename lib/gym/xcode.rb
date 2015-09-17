module Gym
  class Xcode
    class << self
      # Below Xcode 7 (which offers a new nice API to sign the app)
      def pre_7?
        v = xcode_version
        is_pre = v.split('.')[0].to_i < 7
        is_pre
      end
    end
  end
end
