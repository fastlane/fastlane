module Fastlane
  module Actions
    class RestoreFileAction < Action
      def self.run params
        path = params[:path]
        backup_path = "#{path}.back"
        raise "not exist #{backup_path}" unless File.exist? backup_path
        FileUtils.cp(backup_path, path, {:preserve => true})
        FileUtils.rm(backup_path)
      end

      def self.description
        'This action restore your file that backuped in `backup_file` action'
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
                                       description: "Original file name you want to restore",
                                       optional: false),
        ]
      end
    end
  end
end
