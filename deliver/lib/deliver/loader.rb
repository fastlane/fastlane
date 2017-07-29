require 'fastlane_core/languages'

module Deliver
  module Loader
    # The directory 'appleTV' and `iMessage` are special folders that will cause our screenshot gathering code to iterate
    # through it as well searching for language folders.
    APPLE_TV_DIR_NAME = "appleTV".freeze
    IMESSAGE_DIR_NAME = "iMessage".freeze
    DEFAULT_DIR_NAME = "default".freeze
    ALL_LANGUAGES = (FastlaneCore::Languages::ALL_LANGUAGES + [APPLE_TV_DIR_NAME, APPLE_TV_DIR_NAME, IMESSAGE_DIR_NAME, DEFAULT_DIR_NAME]).map(&:downcase).freeze

    def self.language_folders(root)
      Dir.glob(File.join(root, '*')).select do |path|
        File.directory?(path) && ALL_LANGUAGES.include?(File.basename(path).downcase)
      end.sort
    end
  end
end
