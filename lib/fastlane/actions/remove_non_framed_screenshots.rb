module Fastlane
  module Actions
    module SharedValues
      REMOVE_NON_FRAMED_SCREENSHOTS_CUSTOM_VALUE = :REMOVE_NON_FRAMED_SCREENSHOTS_CUSTOM_VALUE
    end

    class RemoveNonFramedScreenshotsAction < Action
      def self.run(params)
        Actions.sh("find #{params[:screenshotsFolder]} -type f -name \"*.png\" | grep -v framed | grep -v #{params[:backgroundImage]} | xargs rm")
      end

      def self.description
        "Removes non-framed screenshots"
      end

      def self.details
        "There seems to be a bug in Deliver that uploads both framed and non-framed
        screenshots. This is a dirty fix until it gets resolved."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :screenshotsFolder,
                                       env_name: "FL_SCREENSHOTS_PATH",
                                       description: "Path to screenshots folder",
                                       is_string: true,
                                       default_value: "fastlane/screenshots/",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :backgroundImage,
                                       env_name: "FL_BACKGROUND_IMAGE_NAME",
                                       description: "Name of background image",
                                       is_string: true,
                                       default_value: "background.png",
                                       optional: true)
        ]
      end

      def self.authors
        ["JagCesar"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
