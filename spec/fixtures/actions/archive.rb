module Fastlane
  module Actions
    module SharedValues
      ARCHIVE = :ARCHIVE
    end

    class ArchiveAction < Action
      def self.run(params)
        puts 'yes'
      end
    end
  end
end
