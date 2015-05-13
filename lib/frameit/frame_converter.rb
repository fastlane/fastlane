module Frameit
  class FrameConverter
    DOWNLOAD_URL = 'https://developer.apple.com/app-store/marketing/guidelines/#images'
    FRAME_PATH = '.frameit/devices_frames'
    
    def run
      self.setup_frames
    end

    def setup_frames
      puts "----------------------------------------------------".green
      puts "Looks like you have no device templates installed".green
      puts "The images can not be pre-installed due to licensing".green
      puts "Press Enter to get started".green
      puts "----------------------------------------------------".green
      STDIN.gets
      
      system("open '#{DOWNLOAD_URL}'")
      puts "----------------------------------------------------".green
      puts "Download the zip files for the following devices".green
      puts "iPhone 6, iPhone 6 Plus, iPhone 5s and iPad mini 3".green
      puts "You only need to download the devices you want to use".green
      puts "Press Enter when you downloaded the zip files".green
      puts "----------------------------------------------------".green
      STDIN.gets

      loop do
        system("mkdir -p '#{templates_path}' && open '#{templates_path}'")
        puts "----------------------------------------------------".green
        puts "Extract the downloaded files into the folder".green
        puts "'#{templates_path}', which should be open in your Finder".green
        puts "You can just copy the whole content into it.".green
        puts "Press Enter when you extracted the files into the given folder".green
        puts "----------------------------------------------------".green
        STDIN.gets

        if not frames_exist?
          puts "Sorry, I can't find the PSD files. Make sure you unzipped them into '#{templates_path}'".red
        else
          break # everything is finished
        end
      end

      convert_frames
    end

    def frames_exist?
      (Dir["#{templates_path}/**/*.psd"].count + Dir["../**/*sRGB.png"].count) > 0
    end

    def templates_path
      "#{ENV['HOME']}/#{FRAME_PATH}"
    end

    # Converts all the PSD files to trimmed PNG files
    def convert_frames
      MiniMagick.configure do |config|
        config.validate_on_create = false
      end

      Dir["#{templates_path}/**/*.psd"].each do |psd|
        resulting_path = psd.gsub('.psd', '.png')
        unless File.exists?resulting_path
          Helper.log.debug "Converting PSD file '#{psd}'".yellow
          image = MiniMagick::Image.open(psd)
          if image
            image.format 'png'
            image.trim
            
            image.write(resulting_path)
          else
            Helper.log.error "Could not parse PSD file at path '#{psd}'"
          end
        end
      end
    end
  end
end
