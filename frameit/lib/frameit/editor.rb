module Frameit
  class Editor
    attr_accessor :screenshot # reference to the screenshot object to fetch the path, title, etc.
    attr_accessor :frame # the frame of the device
    attr_accessor :image # the current image used for editing
    attr_accessor :top_space_above_device

    def frame!(screenshot)
      self.screenshot = screenshot
      prepare_image

      if load_frame # Mac doesn't need a frame
        self.frame = MiniMagick::Image.open(load_frame)
        self.frame.rotate(90) unless self.screenshot.portrait? # we use portrait device frames for landscape screenshots
      elsif self.class == Editor
        # Couldn't find device frame (probably an iPhone 4, for which there are no images available any more)
        # Message is already shown elsewhere
        return
      end

      if should_add_title?
        @image = complex_framing
      else
        # easy mode from 1.0 - no title or background
        width = offset['width']
        image.resize width # resize the image to fit the frame
        put_into_frame # put it in the frame
      end

      store_result # write to file system
    end

    def load_frame
      TemplateFinder.get_template(screenshot)
    end

    def prepare_image
      @image = MiniMagick::Image.open(screenshot.path)
    end

    private

    def store_result
      output_path = screenshot.path.gsub('.png', '_framed.png').gsub('.PNG', '_framed.png')
      image.format("png")
      image.write(output_path)
      UI.success "Added frame: '#{File.expand_path(output_path)}'"
    end

    # puts the screenshot into the frame
    def put_into_frame
      # We have to rotate the screenshot, since the offset information is for portrait
      # only. Instead of doing the calculations ourselves, it's much easier to let
      # imagemagick do the hard lifting for landscape screenshots
      unless self.screenshot.portrait?
        frame.rotate(-90)
        @image.rotate(-90)
      end

      @image = frame.composite(image, "png") do |c|
        c.compose "Over"
        c.geometry offset['offset']
      end

      # We have to revert the state to be landscape screenshots
      unless self.screenshot.portrait?
        frame.rotate(90)
        @image.rotate(90)
      end
    end

    def offset
      return @offset_information if @offset_information

      @offset_information = fetch_config['offset'] || Offsets.image_offset(screenshot)

      if @offset_information and (@offset_information['offset'] or @offset_information['offset'])
        return @offset_information
      end
      UI.user_error! "Could not find offset_information for '#{screenshot}'"
    end

    #########################################################################################
    # Everything below is related to title, background, etc. and is not used in the easy mode
    #########################################################################################

    # this is used to correct the 1:1 offset information
    # the offset information is stored to work for the template images
    # since we resize the template images to have higher quality screenshots
    # we need to modify the offset information by a certain factor
    def modify_offset(multiplicator)
      # Format: "+133+50"
      hash = offset['offset']
      x = hash.split("+")[1].to_f * multiplicator
      y = hash.split("+")[2].to_f * multiplicator
      new_offset = "+#{x.round}+#{y.round}"
      @offset_information['offset'] = new_offset
    end

    # Do we add a background and title as well?
    def should_add_title?
      return (fetch_config['background'] and (fetch_config['title'] or fetch_config['keyword']))
    end

    # more complex mode: background, frame and title
    def complex_framing
      background = generate_background

      if self.frame # we have no frame on le mac
        resize_frame!
        put_into_frame

        # Decrease the size of the framed screenshot to fit into the defined padding + background
        frame_width = background.width - horizontal_frame_padding * 2
        @image.resize "#{frame_width}x"
      end

      self.top_space_above_device = vertical_frame_padding

      if fetch_config['title']
        background = put_title_into_background(background)
      end

      @image = put_device_into_background(background)

      image
    end

    # Horizontal adding around the frames
    def horizontal_frame_padding
      padding = fetch_config['padding']
      unless padding.kind_of?(Integer)
        padding = padding.split('x')[0].to_i
      end
      return scale_padding(padding)
    end

    # Vertical adding around the frames
    def vertical_frame_padding
      padding = fetch_config['padding']
      unless padding.kind_of?(Integer)
        padding = padding.split('x')[1].to_i
      end
      return scale_padding(padding)
    end

    def scale_padding(padding)
      multi = 1.0
      multi = 1.7 if self.screenshot.triple_density?
      return padding * multi
    end

    # Returns a correctly sized background image
    def generate_background
      background = MiniMagick::Image.open(fetch_config['background'])

      if background.height != screenshot.size[1]
        background.resize "#{screenshot.size[0]}x#{screenshot.size[1]}!" # `!` says it should ignore the ratio
      end
      background
    end

    def put_device_into_background(background)
      show_complete_frame = fetch_config['show_complete_frame']
      if show_complete_frame
        max_height = background.height - top_space_above_device
        image.resize "x#{max_height}>"
      end

      left_space = (background.width / 2.0 - image.width / 2.0).round

      @image = background.composite(image, "png") do |c|
        c.compose "Over"
        c.geometry "+#{left_space}+#{top_space_above_device}"
      end

      return image
    end

    # Resize the frame as it's too low quality by default
    def resize_frame!
      screenshot_width = self.screenshot.portrait? ? screenshot.size[0] : screenshot.size[1]

      multiplicator = (screenshot_width.to_f / offset['width'].to_f) # by how much do we have to change this?
      new_frame_width = multiplicator * frame.width # the new width for the frame
      frame.resize "#{new_frame_width.round}x" # resize it to the calculated witdth
      modify_offset(multiplicator) # modify the offset to properly insert the screenshot into the frame later
    end

    # Add the title above the device
    def put_title_into_background(background)
      title_images = build_title_images(image.width, image.height)

      keyword = title_images[:keyword]
      title = title_images[:title]

      # sum_width: the width of both labels together including the space inbetween
      #   is used to calculate the ratio
      sum_width = title.width
      sum_width += keyword.width + keyword_padding if keyword

      # Resize the 2 labels if necessary
      smaller = 1.0 # default
      ratio = (sum_width + keyword_padding * 2) / image.width.to_f
      if ratio > 1.0
        # too large - resizing now
        smaller = (1.0 / ratio)

        UI.verbose("Text for image #{self.screenshot.path} is quite long, reducing font size by #{(ratio - 1.0).round(2)}")

        title.resize "#{(smaller * title.width).round}x"
        keyword.resize "#{(smaller * keyword.width).round}x" if keyword
        sum_width *= smaller
      end

      vertical_padding = vertical_frame_padding
      top_space = vertical_padding
      left_space = (background.width / 2.0 - sum_width / 2.0).round

      self.top_space_above_device += title.height + vertical_padding

      # First, put the keyword on top of the screenshot, if we have one
      if keyword
        background = background.composite(keyword, "png") do |c|
          c.compose "Over"
          c.geometry "+#{left_space}+#{top_space}"
        end

        left_space += keyword.width + (keyword_padding * smaller)
      end

      # Then, put the title on top of the screenshot next to the keyword
      background = background.composite(title, "png") do |c|
        c.compose "Over"
        c.geometry "+#{left_space}+#{top_space}"
      end
      background
    end

    def actual_font_size
      [@image.width / 10.0].max.round
    end

    # The space between the keyword and the title
    def keyword_padding
      (actual_font_size / 2.0).round
    end

    # This will build 2 individual images with the title, which will then be added to the real image
    def build_title_images(max_width, max_height)
      words = [:keyword, :title].keep_if { |a| fetch_text(a) } # optional keyword/title
      results = {}
      words.each do |key|
        # Create empty background
        empty_path = File.join(Frameit::ROOT, "lib/assets/empty.png")
        title_image = MiniMagick::Image.open(empty_path)
        image_height = max_height # gets trimmed afterwards anyway, and on the iPad the `y` would get cut
        title_image.combine_options do |i|
          # Oversize as the text might be larger than the actual image. We're trimming afterwards anyway
          i.resize "#{max_width * 5.0}x#{image_height}!" # `!` says it should ignore the ratio
        end

        current_font = font(key)
        text = fetch_text(key)
        UI.verbose("Using #{current_font} as font the #{key} of #{screenshot.path}") if current_font
        UI.verbose("Adding text '#{text}'")

        text.gsub! '\n', "\n"
        text.gsub!(/(?<!\\)(')/) { |s| "\\#{s}" } # escape unescaped apostrophes with a backslash

        interline_spacing = fetch_config['interline_spacing']

        # Add the actual title
        title_image.combine_options do |i|
          i.font current_font if current_font
          i.gravity "Center"
          i.pointsize actual_font_size
          i.draw "text 0,0 '#{text}'"
          i.interline_spacing interline_spacing if interline_spacing
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
      config_path = File.join(File.expand_path("../..", screenshot.path), "Framefile.json") unless File.exist?(config_path)
      file = ConfigParser.new.load(config_path)
      return {} unless file # no config file at all
      @config = file.fetch_value(screenshot.path)
    end

    # Fetches the title + keyword for this particular screenshot
    def fetch_text(type)
      UI.user_error! "Valid parameters :keyword, :title" unless [:keyword, :title].include? type

      # Try to get it from a keyword.strings or title.strings file
      strings_path = File.join(File.expand_path("..", screenshot.path), "#{type}.strings")
      if File.exist? strings_path
        parsed = StringsParser.parse(strings_path)
        result = parsed.find { |k, v| screenshot.path.upcase.include? k.upcase }
        return result.last if result
      end

      # No string files, fallback to Framefile config
      result = fetch_config[type.to_s]['text'] if fetch_config[type.to_s]
      UI.verbose("Falling back to default text as there was nothing specified in the .strings file")

      if type == :title and !result
        # title is mandatory
        UI.user_error! "Could not get title for screenshot #{screenshot.path}. Please provide one in your Framefile.json"
      end

      return result
    end

    # The font we want to use
    def font(key)
      single_font = fetch_config[key.to_s]['font']
      return single_font if single_font

      fonts = fetch_config[key.to_s]['fonts']
      if fonts
        fonts.each do |font|
          if font['supported']
            font['supported'].each do |language|
              if screenshot.path.include? language
                return font["font"]
              end
            end
          else
            # No `supported` array, this will always be true
            UI.verbose("Found a font with no list of supported languages, using this now")
            return font["font"]
          end
        end
      end

      UI.verbose("No custom font specified for #{screenshot}, using the default one")
      return nil
    end
  end
end
