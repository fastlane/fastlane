module Fastlane
  module Actions
    class XctoolAction

      def self.is_supported?(type)
        type == :ios
      end
      
      def self.run(params)
        unless Helper.test?
          raise 'xctool not installed, please install using `brew install xctool`'.red if `which xctool`.length == 0
        end

        Actions.sh('xctool ' + params.join(' '))
      end
    end
  end
end
