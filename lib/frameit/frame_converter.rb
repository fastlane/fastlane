module Frameit
  class FrameConverter
    TEMPLATES_PATH = './devices'

    # Converts all the PSD files to trimmed PNG files
    def run

      Dir["#{TEMPLATES_PATH}/**/*.psd"].each do |psd|
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