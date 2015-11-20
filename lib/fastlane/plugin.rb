module Fastlane
  module Plugin
    module ClassMethods
      def repository
        @repository ||= []
      end

      def inherited(klass)
        repository << klass
        puts "Loaded Plugin #{klass}" #TODO: In the real implementation we would make this only happen to those loaded via fastfile
      end
    end

    def self.included(klass)
      klass.extend ClassMethods  # Somewhat controversial
    end
  end
end
