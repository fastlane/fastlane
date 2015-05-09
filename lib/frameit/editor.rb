module Frameit
  class Editor
    attr_accessor :screenshot

    def frame!(screenshot)
      @screenshot = screenshot

      template_path = TemplateFinder.get_template(screenshot)
      if template_path
        template = MiniMagick::Image.open(template_path)
        image = MiniMagick::Image.open(screenshot.path)

        offset_information = Offsets.image_offset(screenshot)
        raise "Could not find offset_information for '#{screenshot}'" unless (offset_information and offset_information[:width])
        width = offset_information[:width]
        image.resize width

        image = template.composite(image, "png") do |c|
          c.compose "Over"
          c.geometry offset_information[:offset]
        end
        
        if fetch_config['background'] and fetch_config['title'] and fetch_config['keyword']
          image = add_title(image)
        end

        output_path = screenshot.path.gsub('.png', '_framed.png').gsub('.PNG', '_framed.png')
        image.format "png"
        image.write output_path
        Helper.log.info "Added frame: '#{File.expand_path(output_path)}'".green
      end
    end


    private
      def add_title(image)
        # If the user defined a background + title, here we go
        if fetch_config['background']
          background = MiniMagick::Image.open(fetch_config['background'])
          if background.height != screenshot.size[1]
            background.resize "#{screenshot.size[0]}x#{screenshot.size[1]}!" # `!` says it should ignore the ratio
          end

          # First off, change the size of `image` to match the background + padding
          frame_width = background.width - fetch_config['padding'] * 2
          image.resize "#{frame_width}x"

          left_space = (background.width / 2.0 - image.width / 2.0).round
          bottom_space = -(image.height / 10).round # to be just a bit below the image bottom
          device_top = background.height - image.height - bottom_space

          image = background.composite(image, "png") do |c|
            c.compose "Over"
            c.geometry "+#{left_space}+#{device_top}"
          end

          if fetch_config['title']
            title_images = build_title_images(image.width)
            keyword = title_images[:keyword]
            title = title_images[:title]

            sum_width = (keyword.width rescue 0) + title.width + keyword_padding
            top_space = (device_top / 2.0 - actual_font_size / 2.0).round # centered
            
            left_space = (image.width / 2.0 - sum_width / 2.0).round
            if keyword
              image = image.composite(keyword, "png") do |c|
                c.compose "Over"
                c.geometry "+#{left_space}+#{top_space}"
              end
            end

            left_space += (keyword.width rescue 0) + keyword_padding
            image = image.composite(title, "png") do |c|
              c.compose "Over"
              c.geometry "+#{left_space}+#{top_space}"
            end
          end
        end
        image
      end

      def actual_font_size
        (screenshot.size[0] / 20.0).round # depends on the width of the screenshot
      end

      def keyword_padding
        (actual_font_size / 2.0).round
      end

      # This will assemble one image containing the 2 title parts
      def build_title_images(max_width)
        words = [:keyword, :title].keep_if{ |a| fetch_text(a) } # optional keyword/title
        results = {}
        words.each do |key|
          # Create empty background
          empty_path = File.join(Helper.gem_path('frameit'), "lib/assets/empty.png")
          title_image = MiniMagick::Image.open(empty_path)
          title_image.combine_options do |i|
            i.resize "#{max_width}x#{actual_font_size}!" # `!` says it should ignore the ratio
          end

          # Add the actual title
          font = fetch_config[key.to_s]['font']
          title_image.combine_options do |i|
            i.font font if font
            i.gravity "Center"
            i.pointsize actual_font_size
            i.draw "text 0,0 '#{fetch_text(key)}'"
            i.fill fetch_config[key.to_s]['color']
          end
          title_image.trim # remove white space

          results[key] = title_image
        end
        results
      end

      # Loads the config (colors, background, texts, etc.)
      # Don't use this method to access the actual text and use `fetch_texts` instead
      def fetch_config
        return @config if @config

        config_path = File.join(File.expand_path("..", screenshot.path), "Framefile.json")
        config_path = File.join(File.expand_path("../..", screenshot.path), "Framefile.json") unless File.exists?config_path
        file = ConfigParser.new.load(config_path)
        return {} unless file # no config file at all
        @config = file.fetch_value(screenshot.path)
      end

      # Fetches the title + keyword for this particular screenshot
      def fetch_text(type)
        raise "Valid parameters :keyword, :title" unless [:keyword, :title].include?type

        # Try to get it from a keyword.strings or title.strings file
        strings_path = File.join(File.expand_path("..", screenshot.path), "#{type.to_s}.strings")
        if File.exists?strings_path
          parsed = StringsParser.parse(strings_path)
          result = parsed.find { |k, v| screenshot.path.include?k }
          return result.last if result
        end

        # No string files, fallback to Framefile config
        result = fetch_config[type.to_s]['text']      

        if !result and type == :title
          # title is mandatory
          raise "Could not get title for screenshot #{screenshot.path}. Please provide one in your Framefile.json".red
        end

        return result
      end

  end
end