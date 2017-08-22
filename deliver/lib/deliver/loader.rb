require 'fastlane_core/languages'

module Deliver
  module Loader
    # The directory 'appleTV' and `iMessage` are special folders that will cause our screenshot gathering code to iterate
    # through it as well searching for language folders.
    APPLE_TV_DIR_NAME = "appleTV".freeze
    IMESSAGE_DIR_NAME = "iMessage".freeze
    DEFAULT_DIR_NAME = "default".freeze

    SPECIAL_DIR_NAMES = [APPLE_TV_DIR_NAME, IMESSAGE_DIR_NAME, DEFAULT_DIR_NAME].freeze

    EXCEPTION_DIRECTORIES = UploadMetadata::ALL_META_SUB_DIRS.map(&:downcase).freeze

    def self.language_folders(root)
      folders = Dir.glob(File.join(root, '*'))

      if Helper.is_test?
        available_languages = FastlaneCore::Languages::ALL_LANGUAGES
      else
        available_languages = Spaceship::Tunes.client.available_languages.sort
      end

      allowed_directory_names = (available_languages + SPECIAL_DIR_NAMES).map(&:downcase).freeze

      selected_folders = folders.select do |path|
        File.directory?(path) && allowed_directory_names.include?(File.basename(path).downcase)
      end.sort

      # Gets list of folders that are not supported languages
      rejected_folders = folders.select do |path|
        normalized_path = File.basename(path).downcase
        File.directory?(path) && !allowed_directory_names.include?(normalized_path) && !EXCEPTION_DIRECTORIES.include?(normalized_path)
      end.sort

      unless rejected_folders.empty?
        rejected_folders = rejected_folders.map { |path| File.basename(path) }
        UI.user_error! "Unsupport directory name(s) for screenshots/metadata: #{rejected_folders.join(', ')}\n\nValid languages are: #{allowed_directory_names}"
      end

      selected_folders
    end
  end
end
