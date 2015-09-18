require 'json'
require 'supply/version'
require 'supply/options'
require 'supply/client'
require 'supply/listing'
require 'supply/uploader'

require 'fastlane_core'

module Supply
  # Use this to just setup the configuration attribute and set it later somewhere else
  class << self
    attr_accessor :config
  end

  AVAILABLE_METADATA_FIELDS = %w(title short_description full_description video)

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
end
