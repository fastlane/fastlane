module Fastlane
  module Actions

    class PemAction
      def self.run(params)
        unless Helper.test?
            raise 'pem is not installed, please install using `[sudo] gem install pem`'.red if `which pem`.length == 0
        end
        params = params.first
        
        command = 'pem'
        command = 'pem --development' if params == :development

        Actions.sh command
      end
    end
  end
end