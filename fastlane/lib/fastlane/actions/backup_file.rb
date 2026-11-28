module Fastlane
  module Actions
    class BackupFileAction < Action
      def self.run(params)
        path = params[:path]
        FileUtils.cp(path, "#{path}.back", preserve: true)
        UI.message("Successfully created a backup 💾")
      end

      def self.description
        'This action backs up your file to "[path].back"'
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
                                       description: "Path to the file you want to backup",
                                       optional: false)
        ]
      end

      def self.example_code
        [
          'backup_file(path: "/path/to/file")'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
