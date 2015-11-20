require 'fastlane_core/languages'

module Deliver
  module Loader
    ALL_LANGUAGES = FastlaneCore::Languages::ALL_LANGUAGES.map(&:downcase).freeze

    def self.language_folders(root)
      Dir.glob(File.join(root, '*')).select do |path|
        File.directory?(path) && ALL_LANGUAGES.include?(File.basename(path).downcase)
      end.sort
    end
  end
end
