require_relative 'module'
require_relative 'frame_downloader'

module Frameit
  class Offsets
    # Returns the image offset needed for a certain device type
    def self.image_offset(screenshot)
      require 'json'

      unless @offsets_cache
        offsets_json_path = File.join(FrameDownloader.new.templates_path, "offsets.json")
        UI.user_error!("Could not find offsets.json file at path '#{offsets_json_path}'") unless File.exist?(offsets_json_path)
        @offsets_cache = JSON.parse(File.read(offsets_json_path))
      end

      offset_value = @offsets_cache["portrait"][sanitize_device_name(screenshot.device_name)]

      unless offset_value
        unless @embedded_offsets_cache
          embedded_offsets_path = File.join(Frameit::ROOT, "lib", "assets", "frames", "offsets.json")
          if File.exist?(embedded_offsets_path)
            @embedded_offsets_cache = JSON.parse(File.read(embedded_offsets_path))
          end
        end
        offset_value = @embedded_offsets_cache["portrait"][sanitize_device_name(screenshot.device_name)] if @embedded_offsets_cache
      end

      UI.error("Tried looking for offset information for 'portrait', #{screenshot.device_name}") unless offset_value
      return offset_value
    end

    def self.sanitize_device_name(basename)
      # this should be the same as frames_generator's sanitize_device_name (except stripping colors):
      basename = basename.gsub("Apple", "")
      basename = basename.gsub("-", " ")
      basename.strip.to_s
    end
  end
end
