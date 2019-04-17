module Fastlane
  module Actions
    module SharedValues
      SCREENGRAB_OUTPUT_DIRECTORY = :SCREENGRAB_OUTPUT_DIRECTORY
    end

    class CaptureAndroidScreenshotsAction < Action
      def self.run(params)
        require 'screengrab'

        Screengrab.config = params
        Screengrab.android_environment = Screengrab::AndroidEnvironment.new(params[:android_home],
                                                                            params[:build_tools_version])
        Screengrab::DependencyChecker.check(Screengrab.android_environment)
        Screengrab::Runner.new.run

        Actions.lane_context[SharedValues::SCREENGRAB_OUTPUT_DIRECTORY] = File.expand_path(params[:output_directory])

        true
      end

      def self.description
        'Automated localized screenshots of your Android app (via _screengrab_)'
      end

      def self.available_options
        require 'screengrab'
        Screengrab::Options.available_options
      end

      def self.output
        [
          ['SCREENGRAB_OUTPUT_DIRECTORY', 'The path to the output directory']
        ]
      end

      def self.author
        ['asfalcone', 'i2amsam', 'mfurtak']
      end

      def self.is_supported?(platform)
        platform == :android
      end

      def self.example_code
        [
          'capture_android_screenshots',
          'screengrab # alias for "capture_android_screenshots"',
          'capture_android_screenshots(
            locales: ["en-US", "fr-FR", "ja-JP"],
            clear_previous_screenshots: true,
            app_apk_path: "build/outputs/apk/example-debug.apk",
            tests_apk_path: "build/outputs/apk/example-debug-androidTest-unaligned.apk"
          )'
        ]
      end

      def self.category
        :screenshots
      end
    end
  end
end
