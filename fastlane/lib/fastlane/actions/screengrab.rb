module Fastlane
  module Actions
    module SharedValues
      SCREENGRAB_OUTPUT_DIRECTORY = :SCREENGRAB_OUTPUT_DIRECTORY
    end

    class ScreengrabAction < Action
      def self.run(params)
        require 'screengrab'

        begin
          FastlaneCore::UpdateChecker.start_looking_for_update('screengrab') unless Helper.is_test?

          Screengrab.config = params
          Screengrab.android_environment = Screengrab::AndroidEnvironment.new(params[:android_home],
                                                                              params[:build_tools_version])
          Screengrab::DependencyChecker.check(Screengrab.android_environment)
          Screengrab::Runner.new.run

          Actions.lane_context[SharedValues::SCREENGRAB_OUTPUT_DIRECTORY] = File.expand_path(params[:output_directory])

          true
        ensure
          FastlaneCore::UpdateChecker.show_update_status('screengrab', Screengrab::VERSION)
        end
      end

      def self.description
        'Automated localized screenshots of your Android app on every device'
      end

      def self.available_options
        require 'screengrab'
        Screengrab::Options.available_options
      end

      def self.author
        ['asfalcone', 'i2amsam', 'mfurtak']
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end
