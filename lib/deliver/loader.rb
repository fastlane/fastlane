require 'fastlane_core/languages'

module Deliver
  module Loader
    # The directory 'appleTV' is a special folder that will cause our screenshot gathering code to iterate
    # through it as well searching for language folders.
    APPLE_TV_DIR_NAME = "appleTV"
    ALL_LANGUAGES = (FastlaneCore::Languages::ALL_LANGUAGES + [APPLE_TV_DIR_NAME]).map(&:downcase).freeze

    def self.language_folders(root)
      Dir.glob(File.join(root, '*')).select do |path|
        File.directory?(path) && ALL_LANGUAGES.include?(File.basename(path).downcase)
      end.sort
    end
  end
end
