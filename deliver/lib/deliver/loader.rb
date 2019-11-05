require 'fastlane_core/languages'
require 'spaceship/tunes/tunes'

require_relative 'module'
require_relative 'upload_metadata'

module Deliver
  module Loader
    # The directory 'appleTV' and `iMessage` are special folders that will cause our screenshot gathering code to iterate
    # through it as well searching for language folders.
    APPLE_TV_DIR_NAME = "appleTV".freeze
    IMESSAGE_DIR_NAME = "iMessage".freeze
    DEFAULT_DIR_NAME = "default".freeze

    SPECIAL_DIR_NAMES = [APPLE_TV_DIR_NAME, IMESSAGE_DIR_NAME, DEFAULT_DIR_NAME].freeze

    # Some exception directories may exist from other actions that should not be iterated through
    SUPPLY_DIR_NAME = "android".freeze
    FRAMEIT_FONTS_DIR_NAME = "fonts".freeze
    META_DIR_NAMES = UploadMetadata::ALL_META_SUB_DIRS.map(&:downcase)

    EXCEPTION_DIRECTORIES =  (META_DIR_NAMES << SUPPLY_DIR_NAME << FRAMEIT_FONTS_DIR_NAME).freeze

    def self.language_folders(root, ignore_validation)
      folders = Dir.glob(File.join(root, '*'))

      if Helper.test?
        available_languages = FastlaneCore::Languages::ALL_LANGUAGES
      else
        available_languages = Spaceship::Tunes.client.available_languages.sort
      end

      allowed_directory_names_with_case = (available_languages + SPECIAL_DIR_NAMES)
      allowed_directory_names = allowed_directory_names_with_case.map(&:downcase).freeze

      selected_folders = folders.select do |path|
        File.directory?(path) && allowed_directory_names.include?(File.basename(path).downcase)
      end.sort

      # Gets list of folders that are not supported languages
      rejected_folders = folders.select do |path|
        normalized_path = File.basename(path).downcase
        File.directory?(path) && !allowed_directory_names.include?(normalized_path) && !EXCEPTION_DIRECTORIES.include?(normalized_path)
      end.sort

      if !ignore_validation && !rejected_folders.empty?
        rejected_folders = rejected_folders.map { |path| File.basename(path) }
        UI.user_error!("Unsupported directory name(s) for screenshots/metadata in '#{root}': #{rejected_folders.join(', ')}" \
                       "\nValid directory names are: #{allowed_directory_names_with_case}" \
                       "\n\nEnable 'ignore_language_directory_validation' to prevent this validation from happening")
      end

      selected_folders
    end
  end
end
