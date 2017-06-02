require 'fastlane_core/languages'

module Deliver
  module Loader
    # The directory 'appleTV' and `iMessage` are special folders that will cause our screenshot gathering code to iterate
    # through it as well searching for language folders.
    APPLE_TV_DIR_NAME = "appleTV".freeze
    IMESSAGE_DIR_NAME = "iMessage".freeze
    DEFAULT_DIR_NAME = "default".freeze
    ALL_LANGUAGES = (FastlaneCore::Languages::ALL_LANGUAGES + [APPLE_TV_DIR_NAME, APPLE_TV_DIR_NAME, IMESSAGE_DIR_NAME, DEFAULT_DIR_NAME]).map(&:downcase).freeze

    EXCEPTION_DIRECTORIES = UploadMetadata::ALL_META_SUB_DIRS.map(&:downcase).freeze

    def self.language_folders(root, skip_unsupported_languages = true)
      folders = Dir.glob(File.join(root, '*'))

      selected_folders = folders.select do |path|
        File.directory?(path) && ALL_LANGUAGES.include?(File.basename(path).downcase)
      end.sort

      # Gets list of folders that are not supported languages
      rejected_folders = folders.select do |path|
        normalized_path = File.basename(path).downcase
        File.directory?(path) && !ALL_LANGUAGES.include?(normalized_path) && !EXCEPTION_DIRECTORIES.include?(normalized_path)
      end.sort

      # Does not raise user error if not skip_unsupported_languages
      unless rejected_folders.empty?
        rejected_folders = rejected_folders.map { |path| File.basename(path) }
        if skip_unsupported_languages
          UI.error "Skipping unsupported language(s) for screenshots/metadata: #{rejected_folders.join(', ')}"
        else
          UI.user_error! "Unsupport language(s) for screenshots/metadata: #{rejected_folders.join(', ')}"
        end
      end

      selected_folders
    end
  end
end
