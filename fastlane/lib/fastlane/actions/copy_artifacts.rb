require 'fileutils'

module Fastlane
  module Actions
    class CopyArtifactsAction < Action
      def self.run(params)
        # we want to make sure that our target folder exist already
        FileUtils.mkdir_p(params[:target_path])

        # Replace any spaces in any of the artifact paths with '\ '
        artifacts = params[:artifacts].map { |e| e.tr(' ', '\ ') }

        if params[:verbose]
          UI.message("Copying artifacts #{artifacts.join(', ')} to #{params[:target_path]}")
          UI.message(params[:keep_original] ? "Keeping originals files" : "Not keeping original files")
        end

        if params[:fail_on_missing]
          missing = artifacts.select { |a| !File.exist?(a) }
          UI.error "Not all files were present in copy artifacts. \
                      Missing #{missing.join(', ')}" unless missing.empty?
        end

        if params[:keep_original]
          FileUtils.cp_r(artifacts, params[:target_path], remove_destination: true)
        else
          FileUtils.mv(artifacts, params[:target_path], force: true)
        end

        UI.success('Build artifacts successfully copied!')
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Small action to save your build artifacts. Useful when you use reset_git_repo"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :keep_original,
                                       description: "Set this to true if you want copy, rather than move, semantics",
                                       is_string: false,
                                       optional: true,
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :target_path,
                                       description: "The directory in which you want your artifacts placed",
                                       is_string: false,
                                       optional: false,
                                       default_value: 'artifacts'),
          FastlaneCore::ConfigItem.new(key: :artifacts,
                                       description: "An array of file patterns of the files/folders you want to preserve",
                                       is_string: false,
                                       optional: false,
                                       default_value: []),
          FastlaneCore::ConfigItem.new(key: :fail_on_missing,
                                       description: "Fail when a source file isn't found",
                                       is_string: false,
                                       optional: true,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       description: "Print out additional logs that are useful for debugging or tracking the action",
                                       is_string: false,
                                       optional: true,
                                       default_value: false)
        ]
      end

      def self.authors
        ["lmirosevic"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
