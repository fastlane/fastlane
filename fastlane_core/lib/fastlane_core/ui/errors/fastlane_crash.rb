require_relative 'fastlane_exception'

module FastlaneCore
  class Interface
    class FastlaneCrash < FastlaneException
      def prefix
        '[FASTLANE_CRASH]'
      end
    end
  end
end
