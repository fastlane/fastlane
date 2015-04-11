module Fastlane
  module Actions
    module SharedValues
      ARCHIVE = :ARCHIVE
    end

    class ArchiveAction < Action
      def self.run(params)
        raise "Workspace is not set".red unless ENV['WORKSPACE']
        raise "Scheme is not set".red unless ENV['SCHEME']

        Actions.sh("xcodebuild -workspace #{ENV['WORKSPACE']} -scheme #{ENV['SCHEME']} -configuration Debug -destination generic/platform=iOS archive -archivePath #{ENV['SCHEME']}.xcarchive | xcpretty -c")
        Actions.sh("xcodebuild -exportArchive -archivePath #{ENV['SCHEME']}.xcarchive -exportPath #{ENV['SCHEME']} -exportFormat ipa | xcpretty -c")

        ipa_file = "./#{ENV['SCHEME']}.ipa"

        raise "No ipa file found in #{ipa_file}".red unless File.exist?(ipa_file)

        Actions.lane_context[SharedValues::ARCHIVE] = ipa_file
      end
    end
  end
end