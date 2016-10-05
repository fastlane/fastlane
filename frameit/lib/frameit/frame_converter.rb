module Frameit
  class FrameConverter
    DOWNLOAD_URL = 'https://developer.apple.com/app-store/marketing/guidelines/#images'
    FRAME_PATH = '.frameit/devices_frames'

    def run
      self.setup_frames
    end

    def setup_frames
      UI.success "----------------------------------------------------"
      UI.success "Looks like you'd like to install new device templates"
      UI.success "The images can not be pre-installed due to licensing"
      UI.success "Press Enter to get started"
      UI.success "----------------------------------------------------"
      STDIN.gets

      system("open '#{DOWNLOAD_URL}'")
      UI.success "----------------------------------------------------"
      UI.success "Download the zip files for the following devices"
      UI.success "iPhone 7, iPhone 7 Plus, iPhone SE, iPad mini 4 and iPad Pro"
      UI.success "You only need to download the devices you want to use"
      UI.success "Press Enter when you downloaded the zip files"
      UI.success "----------------------------------------------------"
      STDIN.gets

      loop do
        system("mkdir -p '#{templates_path}' && open '#{templates_path}'")
        UI.success "----------------------------------------------------"
        UI.success "Extract the downloaded files into the folder"
        UI.success "'#{templates_path}', which should be open in your Finder"
        UI.success "You can just copy the whole content into it."
        UI.success "Press Enter when you extracted the files into the given folder"
        UI.success "----------------------------------------------------"
        STDIN.gets

        if !frames_exist?
          UI.error "Sorry, I can't find the PSD files. Make sure you unzipped them into '#{templates_path}'"
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
        next if File.exist?(resulting_path)

        UI.important "Converting PSD file '#{psd}'"
        image = MiniMagick::Image.open(psd)

        if psd =~ /iPhone-SE/
          UI.success "Removing white background 🚫 ⬜️"

          # The iPhone-SE screenshots from April 2016 have
          # 3 layers, a background, a product, and the 'put your image here' layer
          # imagemagick seems to add an additional layer with no label which this the
          # composite of all three.  We want to remove the background and composite layer
          good_layers = image.layers.reject do |layer|
            label = layer.details['Properties']['label']
            label.to_s.length == 0 || label =~ /White B/i
          end
          product_layer = good_layers.shift

          good_layers.each do |layer|
            product_layer.layers << layer
          end

          image = product_layer
        end

        if image
          image.format 'png'
          image.trim

          image.write(resulting_path)
        else
          UI.error "Could not parse PSD file at path '#{psd}'"
        end
      end
    end
  end
end
