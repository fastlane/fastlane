module Fastlane
  module Actions
    module SharedValues
      SNAPSHOT_SCREENSHOTS_PATH = :SNAPSHOT_SCREENSHOTS_PATH
    end

    class SnapshotAction < Action
      def self.run(params)
        $verbose = true if params[:verbose]
        clean = !params[:noclean]

        if Helper.test?
          Actions.lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH] = Dir.pwd
          return clean
        end

        require 'snapshot'

        FastlaneCore::UpdateChecker.start_looking_for_update('snapshot') unless Helper.is_test?

        ENV['SNAPSHOT_SKIP_OPEN_SUMMARY'] = "1" # it doesn't make sense to show the HTML page here

        begin
          Dir.chdir(FastlaneFolder.path) do
            Snapshot::SnapshotConfig.shared_instance
            Snapshot::Runner.new.work(clean: clean)

            results_path = Snapshot::SnapshotConfig.shared_instance.screenshots_path

            Actions.lane_context[SharedValues::SNAPSHOT_SCREENSHOTS_PATH] = File.expand_path(results_path) # absolute URL
          end
        ensure
          FastlaneCore::UpdateChecker.show_update_status('snapshot', Snapshot::VERSION)
        end
      end

      def self.description
        "Generate new localised screenshots on multiple devices"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :noclean,
                                       env_name: "FL_SNAPSHOT_NO_CLEAN",
                                       description: "Skips the clean process when building the app",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_SNAPSHOT_VERBOSE",
                                       description: "Print out the UI Automation output",
                                       is_string: false,
                                       default_value: false)
        ]
      end

      def self.author
        "KrauseFx"
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
