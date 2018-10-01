require 'json'
require_relative internal('supply/options')
require_relative internal('supply/client')
require_relative internal('supply/listing')
require_relative internal('supply/apk_listing')
require_relative internal('supply/uploader')

require_relative internal('fastlane_core')

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
