module Fastlane
  module Actions
    module SharedValues
      ARCHIVE_DIR = :ARCHIVE_DIR
    end

    class ExampleActionSecondAction
      def self.run(params)
        puts 'running'
      end
    end
  end
end
