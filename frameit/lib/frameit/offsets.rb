require_relative 'module'
require_relative 'frame_downloader'

module Frameit
  class Offsets
    # Returns the image offset needed for a certain device type
    def self.image_offset(screenshot)
      require 'json'

      unless @offsets_cache
        offsets_json_path =
          File.join(FrameDownloader.new.templates_path, 'offsets.json')
        unless File.exist?(offsets_json_path)
          UI.user_error!(
            "Could not find offsets.json file at path '#{offsets_json_path}'"
          )
        end
        @offsets_cache = JSON.parse(File.read(offsets_json_path))
      end

      offset_value = @offsets_cache['portrait'][screenshot.device_name]
      unless offset_value
        UI.error(
          "Tried looking for offset information for 'portrait', #{screenshot
            .device_name} in '#{offsets_json_path}'"
        )
      end
      return offset_value
    end
  end
end
