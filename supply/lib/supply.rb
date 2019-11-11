require 'json'
require 'supply/options'
require 'supply/client'
require 'supply/listing'
require 'supply/apk_listing'
require 'supply/release_listing'
require 'supply/uploader'
require 'supply/languages'

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

  # https://developers.google.com/android-publisher/#publishing
  module Tracks
    PRODUCTION = "production"
    BETA = "beta"
    ALPHA = "alpha"
    INTERNAL = "internal"

    DEFAULTS = [PRODUCTION, BETA, ALPHA, INTERNAL]
    DEFAULT = PRODUCTION
  end

  # https://developers.google.com/android-publisher/api-ref/edits/tracks
  module ReleaseStatus
    COMPLETED = "completed"
    DRAFT = "draft"
    HALTED = "halted"
    IN_PROGRESS = "inProgress"

    ALL = [COMPLETED, DRAFT, HALTED, IN_PROGRESS]
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  Boolean = Fastlane::Boolean
  ROOT = Pathname.new(File.expand_path('../..', __FILE__))
  DESCRIPTION = "Command line tool for updating Android apps and their metadata on the Google Play Store".freeze
end
