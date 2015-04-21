module Fastlane
  module Actions
    module SharedValues
      ARCHIVE = :ARCHIVE
    end

    class ArchiveAction < Action
      def self.run(_params)
        puts "yes"
      end
    end
  end
end
