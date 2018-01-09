require_relative 'module'
require_relative 'frame_downloader'

module Frameit
  class Offsets
    # Returns the image offset needed for a certain device type for a given orientation
    # uses deliver to detect the screen size
    def self.image_offset(screenshot)
      require 'json'

      unless @offsets
        offsets_json_path = File.join(FrameDownloader.new.templates_path, "offsets.json")
        UI.user_error!("Could not find offsets.json file at path '#{offsets_json_path}'") unless File.exist?(offsets_json_path)
        @offsets = JSON.parse(File.read(offsets_json_path))
      end

      offset_value = @offsets["portrait"][screenshot.device_name]
      UI.error("Tried looking for offset information for 'portrait', #{screenshot.device_name}") unless offset_value
      return offset_value
    end
  end
end
