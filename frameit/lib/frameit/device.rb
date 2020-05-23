require 'fastimage'
require_relative 'module'

module Frameit
  class Device
    REQUIRED_PRIORITY = 999

    attr_reader :id
    attr_reader :deliver_screen_id
    attr_reader :formatted_name
    attr_reader :resolutions
    attr_reader :density_ppi
    attr_reader :default_color
    attr_reader :platform
    attr_reader :priority_config_key

    def initialize(id, formatted_name, priority, resolutions, density_ppi, default_color, platform = Platform::IOS, deliver_screen_id = nil, priority_config_key = nil)
      Raise("Priority mustn't be higher than #{REQUIRED_PRIORITY}") if priority > REQUIRED_PRIORITY
      @id = id
      @deliver_screen_id = deliver_screen_id
      @formatted_name = formatted_name
      @priority = priority
      @resolutions = resolutions
      @density_ppi = density_ppi
      @default_color = default_color
      @platform = platform
      @priority_config_key = priority_config_key
    end

    def priority
      if !priority_config_key.nil? && Frameit.config[priority_config_key]
        REQUIRED_PRIORITY
      else
        @priority
      end
    end

    def is_chosen_platform?(platform)
      @platform == platform || platform == Platform::ANY
    end

    def formatted_name_without_apple
      formatted_name.gsub("Apple", "").strip.to_s
    end

    def self.detect_device(path, platform)
      size = FastImage.size(path)

      UI.user_error!("Could not find or parse file at path '#{path}'") if size.nil? || size.count == 0

      found_device = nil
      filename_device = nil
      filename = Pathname.new(path).basename.to_s
      Devices.constants.each do |c|
        device = Devices.const_get(c)
        next unless device.resolutions.include?(size)
        # assign to filename_device if the filename contains the formatted name / id and its priority is higher than the current filename_device
        filename_device = device if (filename.include?(device.formatted_name_without_apple) || filename.include?(device.id)) && (filename_device.nil? || filename_device.priority < device.priority)
        next unless device.is_chosen_platform?(platform) && (found_device.nil? || device.priority > found_device.priority)
        found_device = device
      end

      # prefer filename
      return filename_device if filename_device

      # return found_device which was detected according to platform & priority & settings if found
      return found_device if found_device

      # no device detected - show error and return nil
      UI.user_error!("Unsupported screen size #{size} for path '#{path}'")
      return nil
    end

    # Previously ENV[FRAMEIT_FORCE_DEVICE_TYPE] was matched to Deliver::AppScreenshot::ScreenSize constants. However,
    # options.rb defined a few Apple devices with unspecified IDs, this option was never read from Frameit.config.
    # Therefore this function matches both ScreenSize constants and formatted names to maintain backward compatibility.
    def self.find_device_by_id_or_name(id)
      return nil if id.nil?
      found_device = nil
      # multiple devices can be matched to the same deliver_screen_id constant -> we return the one with the highest priority
      Devices.constants.each do |c|
        device = Devices.const_get(c)
        if (device.id == id || device.deliver_screen_id == id || device.formatted_name_without_apple == id) && (found_device.nil? || device.priority > found_device.priority)
          found_device = device
        end
      end
      return found_device
    end
  end
end
