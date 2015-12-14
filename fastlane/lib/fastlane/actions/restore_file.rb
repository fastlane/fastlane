module Fastlane
  module Actions
    class RestoreFileAction < Action
      def self.run(params)
        path = params[:path]
        backup_path = "#{path}.back"
        raise "Could not find file '#{backup_path}'" unless File.exist? backup_path
        FileUtils.cp(backup_path, path, {preserve: true})
        FileUtils.rm(backup_path)
        Helper.log.info "Successfully restored backup 📤"
      end

      def self.description
        'This action restore your file that was backuped with the `backup_file` action'
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
                                       description: "Original file name you want to restore",
                                       optional: false)
        ]
      end
    end
  end
end
