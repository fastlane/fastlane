module Fastlane
  module Actions
    class BackupFileAction < Action
      def self.run params
        path = params[:path]
        FileUtils.cp(path, "#{path}.back", {:preserve => true})
      end

      def self.description
        'This action backup your file to "[path].back".'
      end

      def self.is_supported?(platform)
        true
      end

      def self.author
        "gin0606"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "",
                                       description: "File name you want to back up",
                                       optional: false),
        ]
      end
    end
  end
end
