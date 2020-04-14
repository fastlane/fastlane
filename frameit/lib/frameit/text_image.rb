require 'mini_magick'

require_relative 'module'
require_relative 'trim_box'

module Frameit
  # Helper class to clean up the Editor#build_text_images method.
  class TextImage
    attr_accessor :key
    attr_accessor :font
    attr_accessor :font_size
    attr_accessor :text
    attr_accessor :color
    attr_accessor :trim_box
    attr_accessor :image_path
    attr_accessor :tallest_text_height
    attr_accessor :interline_spacing

    attr_reader :files_to_cleanup

    def initialize(key, font, font_size, color, interline_spacing, text)
      @key = key
      @font = font
      @font_size = font_size
      @color = color
      @interline_spacing = interline_spacing
      @text = text
      @files_to_cleanup = []
    end

    def size
      @size ||= compute_size
    end

    def compute_size
      UI.verbose("Measuring text '#{text}'")

      text_image_path = create_image_with_word(text, font, color)

      text_image = MiniMagick::Image.new(text_image_path)

      { width: text_image.width, height: text_image.height }
    end

    def image_path
      raise "Set tallest_text_height first" unless tallest_text_height
      @image_path ||= create_image_with_word(text, font, color, "#{size[:width]}x#{tallest_text_height}")
    end

    def trim_box
      @trim_box ||= compute_trim_box
    end

    def compute_trim_box
      # Natively trimming the image with .trim will result in the loss of the common baseline between the text in all images when side-by-side (e.g. stack_title is false).
      # Hence retrieve the calculated trim bounding box without actually trimming:
      calculated_trim_box = MiniMagick::Image.new(image_path).identify do |b|
        b.format("%@") # CALCULATED: trim bounding box (without actually trimming), see: http://www.imagemagick.org/script/escape.php
      end

      # Create a Trimbox object from the MiniMagick .identify string with syntax "<width>x<height>+<offset_x>+<offset_y>":
      Frameit::Trimbox.new(calculated_trim_box)
    end

    # Create an image fitting the text draw with the specified font and color. If the size is specified, the text will be drawn
    # within this bound. Otherwise, the image will be sized to fit the text.
    # Reference: http://www.imagemagick.org/Usage/text/#label
    def create_image_with_word(text, font, color, size = nil)
      sanitized_text = text.gsub('\n', "\n")
                           .gsub(/(?<!\\)(')/) { |s| "\\#{s}" } # escape unescaped apostrophes with a backslash

      text_image_file = Tempfile.new(['text_image', '.png'])

      # MiniMagick's convert doesn't cleanup after itself like MiniMagick::Image, so we need to track that manually.
      @files_to_cleanup << text_image_file.path

      MiniMagick::Tool::Convert.new do |i|
        i.font(font) if font
        i.gravity("Center")
        i.pointsize(font_size)
        i.background('transparent')
        i.interline_spacing(interline_spacing) if interline_spacing
        i.fill(color)
        i.size(size) if size
        i << "label: #{sanitized_text}"
        i << text_image_file.path
      end

      text_image_file.path
    end
  end
end
