require 'deliver'
require 'fastimage'

module Frameit
  class Runner
    def initialize
      converter = FrameConverter.new
      if converter.frames_exist?
        # Just make sure, the PSD files are converted to PNG
        converter.convert_frames
      else
        # First run
        converter.run
      end
    end

    def run(path, color = nil)
      unless color
        color = Frameit::Color::BLACK
        color = Frameit::Color::SILVER if Frameit.config[:white] || Frameit.config[:silver]
      end

      screenshots = Dir.glob("#{path}/**/*.{png,PNG}").uniq # uniq because thanks to {png,PNG} there are duplicates

      if screenshots.count > 0
        screenshots.each do |full_path|
          next if full_path.include? "_framed.png"
          next if full_path.include? ".itmsp/" # a package file, we don't want to modify that
          next if full_path.include? "device_frames/" # these are the device frames the user is using
          next if full_path.downcase.include? "watch" # we don't care about watches right now

          begin
            screenshot = Screenshot.new(full_path, color)
            screenshot.frame!
          rescue => ex
            UI.error ex.to_s
            UI.error "Backtrace:\n\t#{ex.backtrace.join("\n\t")}" if $verbose
          end
        end
      else
        UI.error "Could not find screenshots in current directory: '#{File.expand_path(path)}'"
      end
    end
  end
end
