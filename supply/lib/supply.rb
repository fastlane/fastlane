require 'json'
require 'supply/options'
require 'supply/client'
require 'supply/listing'
require 'supply/apk_listing'
require 'supply/uploader'

require 'fastlane_core'

module Supply
  # Use this to just setup the configuration attribute and set it later somewhere else
  class << self
    attr_accessor :config
  end

  AVAILABLE_METADATA_FIELDS = %w(title short_description full_description video)
  IMAGES_TYPES = %w(featureGraphic icon promoGraphic tvBanner)
  SCREENSHOT_TYPES = %w(phoneScreenshots sevenInchScreenshots tenInchScreenshots tvScreenshots wearScreenshots)

  IMAGES_FOLDER_NAME = "images"
  IMAGE_FILE_EXTENSIONS = "{png,jpg,jpeg}"

  CHANGELOGS_FOLDER_NAME = "changelogs"

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  ROOT = Pathname.new(File.expand_path('../..', __FILE__))
  DESCRIPTION = "Command line tool for updating Android apps and their metadata on the Google Play Store".freeze
end
